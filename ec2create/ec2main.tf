
variable "myvpc_id" {
  type = string
}

variable "mysubnet_id" { 
type = string
}

variable "myaz" {
  type = string
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYLJRpOFY6oqejmvL7y4OjXDXrHzNYh2ahXmsb5qWy6d/LQVMWqv2hCe7cAuliaQ5cnEelsYFkKQEGwmyOhyCL4NfX1XK7XxrWmWHwxbGRuV/NK8YKVWrRNft+uy2MpsJ0lGwsmFgtj0qKXejaR1tjgqch8umSfKZt8d+Ge7vceU0ahXkcK8sUH29DUXDOk/CPMJq3cjTuEyJLUKO7fWNl63cwP4d1JgLkqbhNc8MM9tCqXhsrqoH/omelcmMtkLYnAlDmRwi0hJJTeibLrYOpxBk9KT+yLLkyZrKrXDfjkUvO6CWmTWmM3zV1XQUVF9qER7ii+/mBVFk8xFaH0dYj aravind@aravind-MintBox"
}


data "aws_subnet" "selected" {
  id = "${var.mysubnet_id}"
}

resource "aws_security_group" "subnet" {
  
  vpc_id = "${var.myvpc_id}"

  ingress {
    #cidr_blocks = ["${data.aws_subnet.selected.cidr_block}"]
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

    ingress {
    #cidr_blocks = ["${data.aws_subnet.selected.cidr_block}"]
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

    egress {
    #cidr_blocks = ["${data.aws_subnet.selected.cidr_block}"]
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_instance" "jazzy" {
  provider =  "aws.aravind"
  ami           = "ami-0a74bfeb190bd404f"
  instance_type = "t2.micro"
  key_name = "deployer-key"
  availability_zone = "${var.myaz}"
  #subnet_id = "${module.vpc.aws_subnet.public.id}"
  #vpc_id            = "${module.vpc.aws_vpc.main.id}"
  subnet_id = "${var.mysubnet_id}"
  vpc_security_group_ids = ["${aws_security_group.subnet.id}"]
  associate_public_ip_address = true
  
  tags = {
   Name = "aravind"
     }


provisioner "file" {
    source     = "/home/aravind/Documents/index_files.zip"
    destination = "/tmp/index.zip"

    connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = "${file("/home/aravind/.ssh/id_rsa")}"
    host     = "${self.public_ip}"
  }
}

 provisioner "remote-exec" {
          /*
          inline = [
              "sudo yum install python3 -y",
              "pip3 install ansible --user",
              "sudo yum install python2 -y",
              "sudo yum install git -y",
              "git clone https://github.com/devops-school/ansible-hello-world-role /tmp/ans_ws",
              "ansible-playbook /tmp/ans_ws/site.yaml"
          ]
          */

          inline = [
          "sudo dnf install httpd -y",
          "sudo dnf install unzip -y",
          #"sudo dnf install firewalld -y",
          "sudo systemctl enable httpd",
          "sudo systemctl start httpd",
          #"sudo firewall-cmd --zone=public --permanent --add-service=http",
          #"sudo firewall-cmd --reload",
          "sudo chown -R ec2-user:users /var/www",
          #"sudo echo 'Hi There, this is aravind ' > /var/www/html/index.html"]
          "cp /tmp/index.zip /var/www/html/",
          "unzip /var/www/html/index.zip -d /var/www/html/"
          ]

      connection {
          type     = "ssh"
          user     = "ec2-user"
          private_key = "${file("/home/aravind/.ssh/id_rsa")}"
          host     = "${self.public_ip}"

        }
      }

  


      
}
