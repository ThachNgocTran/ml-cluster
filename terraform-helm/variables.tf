variable "username" {
  description = "The username for the Postgres database"
  type        = string
  sensitive   = true
  #default     = "postgres_user" ➔ if using, comment out "sensitive".
}

variable "password" {
  description = "The password for the Postgres database"
  type        = string
  sensitive   = true
}

variable "airflow_fernet_key" {
  description = "The airflow fernet key"
  type        = string
  sensitive   = true
}

/* In Terminal ~/.profile ➔ export TF_VAR_username="postgres_user" */
