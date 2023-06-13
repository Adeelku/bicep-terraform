#############
# VARIABLES #
#############

variable "region" {
  description = "(Required) Specifies the Region for the deployment."
  type        = string
}

variable "prefix" {
  type        = string
  description = "(Required) Specifies the Name of the Workload/App."
}

variable "env" {
  type    = string
  default = "dev"
}


