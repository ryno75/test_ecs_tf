provider "vault" {
  # Creds are configured on the Atlantis pod via ENV variables
  version = "1.1.0"
}

data "vault_generic_secret" "dockerhub_creds" {
  path = "secret/ia/dockerhub_creds"
}
