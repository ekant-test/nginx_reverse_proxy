
variable "server_count_min" {
  type        = number
  description = "number of EC2 instances to run as a minimum"
  default     = 1
}

variable "server_count_max" {
  type        = number
  description = "number of EC2 instances to run as a maximum"
  default     = 1
}

variable "server_count_desired" {
  type        = number
  description = "number of EC2 instances to run"
  default     = 1
}

variable "server_instance_type" {
  type        = string
  description = "size of the EC2 instance"
}

variable "server_os_disk_sise" {
  type        = number
  description = "size in GB of the host OS disk"
}
