variable "job_name" {
  type        = string
  description = "Name of the Cloud Scheduler job"

  validation {
    condition     = length(trimspace(var.job_name)) > 0
    error_message = "var.job_name must be a non-empty string"
  }
}

variable "schedule" {
  type        = string
  description = "Cron schedule for the job, e.g. '0 */6 * * *'"

  validation {
    condition     = length(trimspace(var.schedule)) > 0
    error_message = "var.schedule must be a non-empty string"
  }
}

variable "uri" {
  type        = string
  description = "HTTPS target URI the job invokes (typically a Cloud Run service URL)"

  validation {
    condition     = can(regex("^https://", var.uri))
    error_message = "var.uri must be an https:// URL"
  }
}

variable "service_account_email" {
  type        = string
  description = "Dedicated service account used for the job's OIDC token; must not be the default Compute Engine service account"

  validation {
    condition     = !can(regex("-compute@developer\\.gserviceaccount\\.com$", var.service_account_email))
    error_message = "var.service_account_email must not be the default Compute Engine service account"
  }
}