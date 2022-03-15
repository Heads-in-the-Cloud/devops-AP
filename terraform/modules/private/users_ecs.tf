# # External Data imports
# data "aws_ecr_repository" "user_image" {
#   name = "ap-users"
# }

# resource "aws_ecs_cluster" "utopia" {
#   name = "utopia"
# }

# # Application Load Balancer
# resource "aws_lb_target_group" "sun_api" {
#   name        = "sun-api"
#   port        = 3000
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = aws_vpc.app_vpc.id

#   health_check {
#     enabled = true
#     path    = "/health"
#   }

#   depends_on = [aws_alb.sun_api]
# }

# resource "aws_alb" "sun_api" {
#   name               = "sun-api-lb"
#   internal           = false
#   load_balancer_type = "application"

#   subnets = [
#     aws_subnet.public_d.id,
#     aws_subnet.public_e.id,
#   ]

#   security_groups = [
#     aws_security_group.http.id,
#     aws_security_group.https.id,
#     aws_security_group.egress_all.id,
#   ]

#   depends_on = [aws_internet_gateway.igw]
# }

# resource "aws_alb_listener" "sun_api_http" {
#   load_balancer_arn = aws_alb.sun_api.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.sun_api.arn
#   }
# }

# # Users ECS context
# resource "aws_ecs_task_definition" "users_ecs" {
#   family = "users"
#   container_definitions = jsonencode([
#     {
#       name  = "first"
#       image = data.aws_ecr_repository.user_image.name
#       portMappings = [
#         {
#           containerPort = 80
#           hostPort      = 80
#         }
#       ]
#       environment = [
#         {
#           name  = "SPRING_DATASOURCE_USERNAME"
#           value = var.mysql_user
#         },
#         {
#           name  = "SPRING_DATASOURCE_PASSWORD"
#           value = var.mysql_password
#         },
#         {
#           name  = "SPRING_DATASOURCE_URL"
#           value = var.spring_datasource_url
#         }
#       ]
#     }
#   ])

#   cpu    = 256
#   memory = 512

#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
# }

# resource "aws_ecs_service" "users_ecs" {
#   name            = "users-api"
#   task_definition = aws_ecs_task_definition.users_ecs.arn
#   cluster         = aws_ecs_cluster.utopia.id
#   launch_type     = "FARGATE"

#   network_configuration {
#     assign_public_ip = false
#     security_groups = [aws_security_group.ecs_utopia.id]

#     subnets = [var.private_subnet]
#   }
# }
