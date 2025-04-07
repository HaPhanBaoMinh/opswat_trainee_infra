output "rds_endpoint" {
  description = "Endpoint của RDS"
  value       = aws_db_instance.rds_instance.endpoint
}

output "rds_sg_id" {
  description = "ID của Security Group cho RDS"
  value       = aws_security_group.rds_sg.id
}
