# EC2 instance
resource "aws_instance" "instance1" {
    ami = "ami-0a1ee2fb28fe05df3"
    instance_type = "t2.micro"

    # VPC
    subnet_id = aws_subnet.private-subnet1.id

    # Security Group
    vpc_security_group_ids = [aws_security_group.AFERRANC-CCF-sg.id]

    # Public SSH key
    key_name = aws_key_pair.AFERRANC-CCF-Key-WebServer.id

    # Wordpress installation
    provisioner "file" {
        source = "install_wordpress.sh"
        destination = "/tmp/install_wordpress.sh"
    }
    provisioner "remote-exec" {
        inline = [
             "chmod +x /tmp/install_wordpress.sh",
             "sudo /tmp/install_wordpress.sh"
        ]
    }
    connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = file(var.PRIVATE_KEY_PATH)
        host        = self.public_ip
    }
    tags = {
      Name = "AFERRANC-CCF-EC2-WebServer"
    }
}
resource "aws_key_pair" "AFERRANC-CCF-Key-WebServer" {
    key_name = "AFERRANC-CCF-Key-WebServer"
    public_key = file(var.PUBLIC_KEY_PATH)
}

# Application Load Balancer
resource "aws_alb" "wp" {
    name            = "AFERRANC-CCF-alb"
    security_groups = [aws_security_group.AFERRANC-CCF-sg.id]
    subnets         = [aws_subnet.private-subnet1.id, aws_subnet.private-subnet2.id]
    tags = {
      Name = "AFERRANC-CCF-alb"
    }
}

# Target group defintion
resource "aws_alb_target_group" "http-tg" {
    name     = "AFERRANC-CCF-http-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.main.id
    tags = {
      Name = "AFERRANC-CCF-http-tg"
    }
}

# Target Group Attachment with Instance
resource "aws_alb_target_group_attachment" "tgattachment" {
  target_group_arn = aws_alb_target_group.http-tg.arn
  target_id        = aws_instance.instance1.id
  port             = 80
}

# Load balancer HTTP listener 
resource "aws_alb_listener" "listener_http" {
    load_balancer_arn = aws_alb.wp.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
      target_group_arn = aws_alb_target_group.http-tg.arn
      type             = "forward"
    }
}
