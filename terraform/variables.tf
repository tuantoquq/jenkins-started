variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  default     = "1"
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  default     = "1"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"

}

variable "aws_ec2_ubuntu_ami" {
  description = "AWS EC2 Ubuntu AMI"
  type        = string
  default     = "ami-0123c9b6bfb7eb962"

}

variable "aws_instance_type" {
  description = "AWS Instance Type"
  type        = string
  default     = "t2.micro"
}
