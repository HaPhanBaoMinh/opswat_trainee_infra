region = "ap-southeast-1"

name = "opwat-trainee-project"

availability_zones = [
  "ap-southeast-1a",
  "ap-southeast-1b"
]

db_name = "opwat-trainee-project-db"

environment = "dev"

enable_nat_gateway = true

tags = {
  Environment = "dev"
}
