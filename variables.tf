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
  description = "(Required) See the description in the readme"
  type        = string
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
  description = "(Required) See the description in the readme"
  type        = list(any)
}

variable "health_check" {
  description = "(Required) See the description in the readme"
  type        = map(any)
}
