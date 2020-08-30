output "db_host" {

  value = aws_db_instance.my_database_instance.address
}

output "db_port" {

  value = aws_db_instance.my_database_instance.port
}

output "db_username" {

  value = aws_db_instance.my_database_instance.username
}

output "db_password" {

  value = aws_db_instance.my_database_instance.password
}