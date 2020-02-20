output "key_pair_name" {
  value = "${aws_key_pair.auth.key_name}"
}

output "public_key_path" {
  value = "${var.public_key_path}"
}

output "private_key_path" {
  value = "${var.private_key_path}"
}

output "jenkins_master_sg_id" {
  value = "${aws_security_group.JenkinsSG.id}"
}

output "jenkins_slave_sg_id" {
  value = "${aws_security_group.JenkinsSlaveSG.id}"
}

output "jenkins_master_public_ip" {
  value = ["${aws_instance.jenkins_master.*.public_ip}"]
}

output "jenkins_master_public_dns" {
  value = ["${aws_instance.jenkins_master.*.public_dns}"]
}

output "jenkins_slave_public_ip" {
  value = ["${aws_instance.jenkins_slave.*.public_ip}"]
}

output "jenkins_slave_public_dns" {
  value = ["${aws_instance.jenkins_slave.*.public_dns}"]
}

output "ami_id" {
  value = ["${data.aws_ami.ubuntu18.id}"]
}

output "aws_region" {
  value = "${var.aws_region}"
}
