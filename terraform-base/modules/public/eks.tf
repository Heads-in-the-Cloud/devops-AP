resource "aws_route53_record" "eks_record" {
  zone_id     = var.route53_zone_id
  name        = var.eks_record
  type        = "CNAME"
  ttl         = "30"
  records     = ["placeholder.text"]
}