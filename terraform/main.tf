resource "aws_instance" "jenkins_instance" {
  ami                    = var.aws_ec2_ubuntu_ami
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  subnet_id              = data.aws_subnet.jenkins_subnet.id
  instance_type          = var.aws_instance_type
  key_name               = aws_key_pair.jenkins_key_pair.key_name

  tags = {
    Name = "jenkins-instance"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.jenkins_private_rsa.private_key_openssh
      host        = aws_instance.jenkins_instance.public_ip
    }
    inline = [
      "sudo apt update -y",
      "sudo apt-get install ca-certificates curl",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt update -y",
      "sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y",
      "sudo usermod -aG docker $USER",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo docker network create jenkins",
      "sudo docker run --name jenkins-docker --rm --detach --privileged --network jenkins --network-alias docker --env DOCKER_TLS_CERTDIR=/certs --volume jenkins-docker-certs:/certs/client --volume jenkins-data:/var/jenkins_home --publish 2376:2376 docker:dind --storage-driver overlay2",
      "sudo echo 'FROM jenkins/jenkins:2.440.1-jdk17\nUSER root\nRUN apt-get update && apt-get install -y lsb-release\nRUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc https://download.docker.com/linux/debian/gpg\nRUN echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable\" > /etc/apt/sources.list.d/docker.list\nRUN apt-get update && apt-get install -y docker-ce-cli\nUSER jenkins\nRUN jenkins-plugin-cli --plugins json-path-api:2.9.0-33.v2527142f2e1d\nRUN jenkins-plugin-cli --plugins \"blueocean docker-workflow\"' > Dockerfile",
      "sudo docker build -t myjenkins-blueocean:2.440.1-1 .",
      "sudo docker run --name jenkins-blueocean --restart=on-failure --detach --network jenkins --env DOCKER_HOST=tcp://docker:2376 --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 --publish 8080:8080 --publish 50000:50000 --volume jenkins-data:/var/jenkins_home --volume jenkins-docker-certs:/certs/client:ro myjenkins-blueocean:2.440.1-1"
    ]
  }
}

resource "aws_instance" "backend_instance" {
  ami                    = var.aws_ec2_ubuntu_ami
  instance_type          = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  subnet_id              = data.aws_subnet.backend_subnet.id
  key_name               = aws_key_pair.backend_key_pair.key_name

  tags = {
    Name = "backend-instance"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.backend_private_rsa.private_key_openssh
      host        = aws_instance.backend_instance.public_ip
    }
    inline = [
      "sudo apt update -y",
      "sudo apt-get install ca-certificates curl",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt update -y",
      "sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y",
      "sudo usermod -aG docker $USER",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
    ]
  }
}
