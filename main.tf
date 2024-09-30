resource "aws_key_pair" "prod" {
  key_name   = "prod"
  public_key = file("${path.module}/prod.pub")
}

resource "aws_instance" "app_server" {
  ami           = "ami-0ebfd941bbafe70c6"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.prod.key_name

  vpc_security_group_ids = [aws_security_group.allow_all.id]

  tags = {
    Name = "AppServer"
  }
}

resource "aws_ecr_repository" "webapp_repo" {
  name = "webapp-repo"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
