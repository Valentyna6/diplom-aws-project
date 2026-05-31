# Фаєрвол для балансувальника (ALB) - відкриваємо доступ з інтернету
resource "aws_security_group" "alb_sg" {
  name        = "diploma-alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "diploma-alb-sg"
  }
}

# Фаєрвол для серверів (EC2) - дозволяємо трафік ТІЛЬКИ від балансувальника
resource "aws_security_group" "ec2_sg" {
  name        = "diploma-ec2-sg"
  description = "Allow traffic from ALB only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Traffic from ALB on port 3000"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    # Ось тут магія ізоляції: пускаємо тільки тих, хто пройшов через ALB
    security_groups = [aws_security_group.alb_sg.id] 
  }

  # Дозволяємо серверам виходити в інтернет (щоб завантажити наш Docker-образ)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "diploma-ec2-sg"
  }
}