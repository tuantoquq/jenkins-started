resource "tls_private_key" "jenkins_private_rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jenkins_key_pair" {
  key_name   = "jenkins_key_pair"
  public_key = tls_private_key.jenkins_private_rsa.public_key_openssh
  tags = {
    Name = "jenkins-key-pair"
  }
}

resource "tls_private_key" "backend_private_rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "backend_key_pair" {
  key_name   = "backend_key_pair"
  public_key = tls_private_key.backend_private_rsa.public_key_openssh
  tags = {
    Name = "jenkins-key-pair"
  }
}
