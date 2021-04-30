variable "aws_region" {
    default = "ap-east-1"
}

variable "vpc_spoke_cidr" {
  default     = "10.255.0.0/16"
}

variable "vpc_inbound_cidr" {
  default     = "10.1.0.0/16"
}

variable "cpversion" {
    default = "R80.40"
}

variable "management_server_size" {
    default = "m5.xlarge"
}

variable "geocluster_gateway_size" {
    default = "c5.large"
}

variable "project_name" {
    default = "FWD"
}

variable "key_name" {
    default = "tpot"
}

variable "sickey" {
    default = "vpn12345"
}

#Please use "openssl passwd -1" to create a password hash and copy it to here.
variable "password_hash" {
    default = "$1$CK9jJ4Sw$JXuJgThRUbslUqGBaC5nK1"
}

