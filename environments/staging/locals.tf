locals {
  env            = "staging"
  common_tags    = merge({ environment = local.env }, var.tags)
  admin_username = var.admin_username
}
