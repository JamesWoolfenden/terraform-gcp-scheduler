resource "google_cloud_scheduler_job" "main" {
  name     = var.job_name
  schedule = var.schedule
  region   = "europe-west2"

  http_target {
    uri         = var.uri
    http_method = "POST"

    oidc_token {
      service_account_email = var.service_account_email
      audience              = var.uri
    }
  }
}