output "public_subnet_ids"{
    value = aws_subnet.public.*.id 
}
output "security_group"{
    value =aws_security_group.task-sg.id
}
output "vpc_id" {
  value = aws_vpc.ownvpc.id
}