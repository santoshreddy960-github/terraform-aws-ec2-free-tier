provider "aws" {
  region = "us-east-1"
}

# Create a key pair from the local public key file
resource "aws_key_pair" "terra_key" {
  key_name   = "terraform-key"
  public_key = file("${path.module}/terraform-key.pub")
}

# Use the default VPC (as a resource, not a data source)
resource "aws_default_vpc" "default" {}

# Security group to allow SSH and HTTP
resource "aws_security_group" "terra_sg" {
  name        = "terraform-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
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
}

# Launch EC2 Instance
resource "aws_instance" "terra_instance" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 - Free Tier
  instance_type = "t2.micro"
  key_name      = aws_key_pair.terra_key.key_name
  vpc_security_group_ids = [aws_security_group.terra_sg.id]

  tags = {
    Name = "Terraform-EC2"
  }

  provisioner "remote-exec" {
    inline = ["echo Hello from Terraform!"]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/terraform-key")
      host        = self.public_ip
    }
  }
}

resource "aws_ebs_volume" "extra_volume" {
  availability_zone = aws_instance.terra_instance.availability_zone
  size              = 1            # 1 GB for testing
  type              = "gp2"
  tags = {
    Name = "extra-ebs-volume"
  }
}

resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.extra_volume.id
  instance_id = aws_instance.terra_instance.id
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "terraform-demo-bucket-${random_id.bucket_id.hex}"
  force_destroy = true

  tags = {
    Name = "terraform-demo-bucket"
  }
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "demo_log_group" {
  name              = "/terraform/ec2"
  retention_in_days = 7
}