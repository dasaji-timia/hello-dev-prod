variable "subscription_id" {
  description = "The subscription ID for Azure"
  type        = string
}

variable "location" {
  description = "The location for the resources"
  type        = string
  default     = "canadacentral"
}