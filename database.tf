resource "aws_db_instance" "backend-db" {
    identifier        = "backenddb"
    allocated_storage = 10
    storage_type      = "gp2"
    engine            = "postgresql"
    engine_version    = "12.4"
    instance_class    = "db.t2.micro"
    username          = "adminuser"
    password          = "InitialSetup!"
    availability_zone = var.azs[0]
    multi_az          = false # In a prod env, this would be true, and would be at least 2 AZs (more if your backend db allows for such)
    db_subnet_group_name = aws_db_subnet_group.backend-db-subnet.name
    vpc_security_group_ids = [aws_security_group.allow-db-access.id]
    iam_database_authentication_enabled = true
    # storage_encrypted = true # Implies kms_key_id. Necessary for HIPAA, not for a demo.
    # kms_key_id             = <some_key_id> # This would be required in a HIPAA environment, but not for a demo.
}