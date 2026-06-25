resource "google_service_account" "scheduler" {
  account_id   = "scheduler-invoker"
  display_name = "Cloud Scheduler invoker"
}

resource "google_cloud_run_v2_service" "target" {
  name     = "scheduler-target"
  location = "europe-west2"
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    containers {
      image = "gcr.io/cloudrun/hello"
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "scheduler_invoke" {
  name     = google_cloud_run_v2_service.target.name
  location = google_cloud_run_v2_service.target.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.scheduler.email}"
}

# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "scheduler" {
  source                = "../../"
  job_name              = "holden-test-job"
  schedule              = "0 */6 * * *"
  uri                   = google_cloud_run_v2_service.target.uri
  service_account_email = google_service_account.scheduler.email

  depends_on = [
    google_cloud_run_v2_service_iam_member.scheduler_invoke
  ]
}