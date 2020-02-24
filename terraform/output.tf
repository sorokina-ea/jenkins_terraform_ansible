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

output "jenkins_master_private_ip" {
  value = ["${aws_instance.jenkins_master.*.private_ip}"]
}

output "jenkins_master_private_dns" {
  value = ["${aws_instance.jenkins_master.*.private_dns}"]
}

output "jenkins_slave_private_ip" {
  value = ["${aws_instance.jenkins_slave.*.private_ip}"]
}

output "jenkins_slave_private_dns" {
  value = ["${aws_instance.jenkins_slave.*.private_dns}"]
}

output "ami_id" {
  value = ["${data.aws_ami.ubuntu18.id}"]
}

output "aws_region" {
  value = "${var.aws_region}"
}

output "nat_elastic_ip" {
  value = aws_eip.nat.public_ip
}

output "jenkins_master_alb_dns_name" {
  value = aws_alb.jenkins_master_alb.dns_name
}
