locals {
  aws_profile        = "rksandbox"
  region             = "us-west-2"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  dhub_username      = "${data.vault_generic_secret.dockerhub_creds.data["username"]}"
  dhub_password      = "${data.vault_generic_secret.dockerhub_creds.data["password"]}"
}
