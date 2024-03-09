resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow inbound traffic to Jenkins"
  vpc_id      = data.aws_vpc.vpc_app.id
  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Allow inbound traffic to backend"
  vpc_id      = data.aws_vpc.vpc_app.id
  tags = {
    Name = "backend-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_ssh_sg_ingress" {
  security_group_id = aws_security_group.jenkins_sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "jenkins-ssh-sg-ingress"
  }
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_port_sg_ingress" {
  security_group_id = aws_security_group.jenkins_sg.id
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "jenkins-port-sg-ingress"
  }
}

resource "aws_vpc_security_group_egress_rule" "jenkins_allow_all_outbound_tracffic" {
  security_group_id = aws_security_group.jenkins_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "backend_ssh_ingress" {
  security_group_id = aws_security_group.backend_sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "backend_port_ingress" {
  security_group_id = aws_security_group.backend_sg.id
  from_port         = 3000
  to_port           = 3000
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "backend_allow_all_outbound_tracffic" {
  security_group_id = aws_security_group.backend_sg.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
