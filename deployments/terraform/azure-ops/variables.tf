
variable "az_location" {
  description = "The location where resources are created"
  default     = "Germany West Central"
}
variable "az_resource_group_name_devs" {
  description = "Azure resources group for devs"
  default     = "resource-group-demo-devs"
}
variable "az_resource_group_name_ops" {
  description = "Azure resources group for ops"
  default     = "resource-group-demo-ops"
}
variable "az_storage_account_devs" {
}
variable "az_storage_account_ops" {
}
variable "az_storage_tfstate" {
}
variable "date" {
}
