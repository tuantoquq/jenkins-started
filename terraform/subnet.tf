data "aws_subnet" "jenkins_subnet" {
  vpc_id = data.aws_vpc.vpc_app.id
  id     = "subnet-038348d51b79df4bd"

}

data "aws_subnet" "backend_subnet" {
  vpc_id = data.aws_vpc.vpc_app.id
  id     = "subnet-008f5bbedf3482f86"

}
