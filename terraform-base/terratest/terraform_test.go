package test

import Fmt "fmt"
import Json "encoding/json"
import Testing "testing"
import Sort "sort"

import Aws "github.com/gruntwork-io/terratest/modules/aws"
import Assert "github.com/stretchr/testify/assert"
import Terraform "github.com/gruntwork-io/terratest/modules/terraform"

type TerraformInput struct {
	VpcCidr            string `json:"vpc_cidr"`
	AvailabilityZones  string `json:"availability_zones"`
	PublicSubnets      string `json:"public_subnets"`
	PrivateSubnets     string `json:"private_subnets"`
	NatIP              string `json:"nat_ip"`
	Route53ZoneID      string `json:"route53_zone_id"`
	AwsUserID          string `json:"aws_user_id"`
	EcsURL             string `json:"ecs_url"`
	EksURL             string `json:"eks_url"`
	ResourceSecretName string `json:"resource_secret_name"`
}

type ResourceIdSecret struct {
	VpcID            string   `json:"VPC_ID"`
	PrivateSubnetIds []string `json:"PRIVATE_SUBNET_IDS"`
	PublicSubnetIds  []string `json:"PUBLIC_SUBNET_IDS"`
	EcsLbID          string   `json:"ECS_LB_ID"`
}

func TestTerraform(t *Testing.T) {
	awsRegion 		:= "us-east-2"
	awsSecretUrl 	:= "prod/Angel/Terraform"

	Fmt.Println("= Get TFVars from AWS Credentials Manager: =");
	var varFile TerraformInput;
	var availabilityZones []string;
	var publicSubnetsIPs  []string;
	var privateSubnetsIPs []string;

	secret := Aws.GetSecretValue(t, awsRegion, awsSecretUrl);
	Json.Unmarshal([]byte(secret), &varFile);
	Json.Unmarshal([]byte(varFile.AvailabilityZones), &availabilityZones);
	Json.Unmarshal([]byte(varFile.PublicSubnets), &publicSubnetsIPs);
	Json.Unmarshal([]byte(varFile.PrivateSubnets), &privateSubnetsIPs);

	Fmt.Println("=== Setting Up Terraform Options and Resource Deployment: ===");
	terraformOptions := Terraform.WithDefaultRetryableErrors(t, &Terraform.Options{
		TerraformDir: "../",
		NoColor: false,
		Vars: map[string]interface{}{
			"vpc_cidr": varFile.VpcCidr,
			"availability_zone": varFile.AvailabilityZones,
			"public_subnet": varFile.PublicSubnets,
			"private_subnet": varFile.PrivateSubnets,
			"nat_ip": varFile.NatIP,
			"route53_zone_id": varFile.Route53ZoneID,
			"aws_user_id": varFile.AwsUserID,
			"ecs_record": varFile.EcsURL,
			"eks_record": varFile.EksURL,
			"resource_secret_name": varFile.ResourceSecretName,
		},
	});

	defer Terraform.Destroy(t, terraformOptions);
	Terraform.InitAndApply(t, terraformOptions);

	// =======================================================================
	Fmt.Println("== Asserting Network Module: ==");
	vpcId := Terraform.Output(t, terraformOptions, "vpc_id");
	publicSubnetIds := Terraform.OutputList(t, terraformOptions, "public_subnet_ids");
	privateSubnetIds := Terraform.OutputList(t, terraformOptions, "private_subnet_ids");

	Fmt.Println("Public Subnets: ", publicSubnetIds);
	Fmt.Println("Private Subnets: ", privateSubnetIds);

	subnets := Aws.GetSubnetsForVpc(t, vpcId, awsRegion);
	expectedSubnetCount := len(publicSubnetsIPs) + len(privateSubnetsIPs);
	natInstances := Aws.GetEc2InstanceIdsByFilters(t, awsRegion, map[string][]string{
		"instance-state-name":{"running", "pending"},
		"tag:EC2-Tag":{"Nat"},
	});

	// Check if there are the same amount of public and private subnets
	// and that the subnet count is the same as the amount of availability zones.
	Assert.Equal(t, len(publicSubnetsIPs), len(privateSubnetsIPs));
	Assert.Equal(t, len(availabilityZones), len(publicSubnetsIPs));
	Assert.Equal(t, len(availabilityZones), len(privateSubnetsIPs));
	Assert.Equal(t, expectedSubnetCount, len(subnets));
	Assert.Equal(t, len(natInstances), len(privateSubnetsIPs));

	// Test Subnets for their publicness
	for i := 0; i<len(publicSubnetsIPs); i++ {
		Assert.True(t, Aws.IsPublicSubnet(t, publicSubnetIds[i], awsRegion));
		Assert.False(t, Aws.IsPublicSubnet(t, privateSubnetIds[i], awsRegion));
	}

	// =======================================================================
	Fmt.Println("== Asserting Public Module: ==");
	loadBalancerId := Terraform.Output(t, terraformOptions, "lb_id");

	// =======================================================================
	Fmt.Println("== Asserting that resource secrets are correct ==");
	resourceSecret := Aws.GetSecretValue(t, awsRegion, varFile.ResourceSecretName);
	var resourceIdObject ResourceIdSecret;

	Json.Unmarshal([]byte(resourceSecret), &resourceIdObject);

	// Sort the subnets so they should match in for loops.
	// Should produce the same result unless they have different subnets.
	Sort.Strings(publicSubnetIds);
	Sort.Strings(privateSubnetIds);
	Sort.Strings(resourceIdObject.PublicSubnetIds);
	Sort.Strings(resourceIdObject.PrivateSubnetIds);

	// Verify Ids of vpc and load balancer
	Assert.Equal(t, vpcId, resourceIdObject.VpcID);
	Assert.Equal(t, loadBalancerId, resourceIdObject.EcsLbID);

	Fmt.Println("==== Expected Public Subnets: ", publicSubnetIds);
	Fmt.Println("==== Resulting Public Subnets: ", resourceIdObject.PublicSubnetIds);

	Fmt.Println("\n==== Expected Public Subnets: ", privateSubnetIds);
	Fmt.Println("==== Resulting Public Subnets: ", resourceIdObject.PrivateSubnetIds);

	// Checking subnet Ids
	for i:=0; i<len(publicSubnetIds); i++ {
		Assert.Equal(t, publicSubnetIds[i], resourceIdObject.PublicSubnetIds[i]);
		Assert.Equal(t, privateSubnetIds[i], resourceIdObject.PrivateSubnetIds[i]);
	}
}
