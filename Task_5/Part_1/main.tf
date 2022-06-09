provider "aws" {
  region = "us-east-1"
  access_key = "AKIAU2USGA36SNCYC43C"
  secret_key = "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"
}

resource "aws_instance" "Udacity_T2" {
  ami           = "ami-0022f774911c1d690"
  count         = "4"
  instance_type = "t2.micro"
  subnet_id     = "subnet-00cc3e5b228206802"
  tags = {
    Name = "Udacity_T2"
  }
}

resource "aws_instance" "Udacity_M4" {
   ami           = "ami-0022f774911c1d690"
   count         = "2"
   instance_type = "m4.large"
   subnet_id     = "subnet-00cc3e5b228206802"
   tags = {
     Name = "Udacity_M4"
   }
}
