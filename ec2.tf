resource "aws_instance" "My_ec2_instance" {
  ami                     = var.ami
  instance_type           = "t3.micro"
  subnet_id               = aws_subnet.public_subnet_1.id
  vpc_security_group_ids  = [aws_security_group.My_VPC_Security_group.id]
  key_name                = var.key
  associate_public_ip_address = true
  user_data = "${file("install_wp.sh")}"

  tags = {
    Name = "My_ec2_instance"
  }
}