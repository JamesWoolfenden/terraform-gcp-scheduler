resource "google_cloud_scheduler_job" "main" {
  name             = var.job_name
  description      = var.description
  schedule         = var.schedule
  region           = var.region
  attempt_deadline = var.attempt_deadline

  http_target {
    uri         = var.uri
    http_method = "POST"

    oidc_token {
      service_account_email = var.service_account_email
      audience              = var.uri
    }
  }

  retry_config {
    retry_count = 3
  }
}

