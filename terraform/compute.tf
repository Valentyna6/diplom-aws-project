# 1. Створюємо "паспорт" (IAM Role) для серверів, щоб вони могли читати з ECR
resource "aws_iam_role" "ec2_role" {
  name = "diploma_ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "diploma_ec2_profile"
  role = aws_iam_role.ec2_role.name
}

# 2. Балансувальник навантаження (ALB) та Цільова група
resource "aws_lb" "app_alb" {
  name               = "diploma-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "app_tg" {
  name     = "diploma-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# 3. Знаходимо найсвіжіший образ Amazon Linux 2023
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 4. Шаблон запуску серверів (Launch Template) - ЗМІНЕНО НА t3.micro
resource "aws_launch_template" "app_lt" {
  name_prefix   = "diploma-app-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro" 
  
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Скрипт, який виконається автоматично при старті сервера
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    
    # Логін в наш приватний ECR та запуск контейнера
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.app_repo.repository_url}
    docker run -d -p 3000:3000 --restart always ${aws_ecr_repository.app_repo.repository_url}:latest
    EOF
  )
}

# 5. Група автомасштабування (Створює 2 сервери в приватних мережах)
resource "aws_autoscaling_group" "app_asg" {
  name                = "diploma-asg"
  vpc_zone_identifier = module.vpc.private_subnets
  target_group_arns   = [aws_lb_target_group.app_tg.arn]
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}

# 6. Виводимо посилання на сайт у консоль!
output "website_url" {
  value       = aws_lb.app_alb.dns_name
  description = "Скопіюйте це посилання в браузер, щоб побачити ваш сайт"
}