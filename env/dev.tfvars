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

services = {
  "result" = "result"
  "vote"   = "vote"
}

github_owner = "HaPhanBaoMinh"

github_repo = "opswat_trainee_src"

codestar_connection_arn = "arn:aws:codeconnections:ap-southeast-1:026090549419:connection/d7fd6f95-dc05-49a8-8848-b202337acfbd"

account_id = "026090549419"
