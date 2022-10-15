variable "name" {
  description = "(Required) See the description in the readme"
  type        = string
}

variable "description" {
  description = "(Optional) See the description in the readme"
  type        = string
  default     = ""
}

variable "vpc_no" {
  description = "(Optional) Required If vpc_name does not exist. See the description in the readme"
  type        = string
  default     = null
}

variable "vpc_name" {
  description = "(Optional) Required If vpc_no does not exist. See the description in the readme"
  type        = string
  default     = null
}

variable "protocol" {
  description = "(Required) See the description in the readme"
  type        = string
}

variable "port" {
  description = "(Required) See the description in the readme"
  type        = string
}

variable "algorithm_type" {
  description = "(Optional) See the description in the readme"
  type        = string
  default     = "RR"
}

variable "use_sticky_session" {
  description = "(Optional) See the description in the readme"
  type        = bool
  default     = false
}

variable "use_proxy_protocol" {
  description = "(Optional) See the description in the readme"
  type        = bool
  default     = false
}

variable "target_type" {
  description = "(Optional) See the description in the readme"
  type        = string
  default     = "VSVR"
}

variable "target_no_list" {
  description = "(Optional) Required If target_instance_names does not exist. See the description in the readme"
  type        = list(any)
  default     = null
}

variable "target_instance_names" {
  description = "(Optional) Required If target_no_list does not exist. See the description in the readme"
  type        = list(any)
  default     = null
}

variable "health_check" {
  description = "(Required) See the description in the readme"
  type        = map(any)
}
