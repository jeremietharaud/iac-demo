locals {
  resource_name = lower("${var.tags["Environment"]}-${var.tags["Application"]}")
}
