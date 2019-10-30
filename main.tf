
module "vpc" {
  source  = "JamesWoolfenden/vpc/aws"
  version = "0.1.32"
  # insert the 4 required variables here
  cidr         = "10.2.0.0/24"
  zone         = ["A","B","C"]
  common_tags  = {
    AccountType =           "TFTrain"
    Application =           "webserver_hr"
    Environment =           "DEV"
region = "ap-south-1"
provider =  "aws.aravind"
}

  account_name = "Ara_dev_acct"
}


variable myvpc_id {
  type = string
  default = ""
}

variable mysubnet_id {
  type = string
  default = ""
}

variable myaz {
  type = string
  default = "ap-south-1a"
}

module "ec2" {

source = "./ec2create"
mysubnet_id = "${element(module.vpc.public_subnets,0)}"
myvpc_id = "${module.vpc.vpc_id}"
myaz    = "ap-south-1a"

}

