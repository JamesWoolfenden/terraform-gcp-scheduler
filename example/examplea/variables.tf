variable "job_name" {
  description = "The name of the Cloud Scheduler job"
  type        = string

  default = "scheduler-target-job"

  validation {
    condition     = length(var.job_name) <= 500 && can(regex("^[a-z]([-a-z0-9]*[a-z0-9])?$", var.job_name))
    error_message = "The job_name must be 1-500 characters, start with a lowercase letter, and contain only lowercase letters, numbers, or hyphens."
  }
}