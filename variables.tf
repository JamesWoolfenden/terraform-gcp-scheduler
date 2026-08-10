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


variable "region" {
  type        = string
  description = "Region where the Cloud Scheduler job will be created"
  default     = "europe-west2"

  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "var.region must be a non-empty string"
  }
}

variable "description" {
  type        = string
  description = "Human-readable description of the job's purpose, shown in the GCP console"
  default     = null

  validation {
    condition     = var.description == null || length(trimspace(var.description)) > 0
    error_message = "var.description must be null or a non-empty string"
  }
}

variable "attempt_deadline" {
  type        = string
  description = "Deadline for job attempts, e.g. '180s'. Increase if the HTTP target (e.g. a cold-starting Cloud Run service) can take longer than the GCP default of 3 minutes to respond."
  default     = "180s"

  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]{1,9})?s$", var.attempt_deadline))
    error_message = "var.attempt_deadline must be a duration string like '180s'"
  }
}
