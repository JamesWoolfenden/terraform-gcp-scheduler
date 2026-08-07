resource "google_service_account" "run_runtime" {
  account_id   = "scheduler-target-runtime"
  display_name = "Cloud Run runtime identity for scheduler-target"
}

resource "google_service_account" "scheduler_invoker" {
  account_id   = "scheduler-invoker"
  display_name = "Cloud Scheduler invoker"
}

resource "google_binary_authorization_policy" "project" {
  global_policy_evaluation_mode = "ENABLE"

  default_admission_rule {
    evaluation_mode  = "ALWAYS_ALLOW"
    enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
  }
}

# holden:ignore:HLD_GCP_126: small example, so we don't need to use a separate module for this
# holden:ignore:HLD_GCP_127: small example, so we don't need to use a separate module for this
resource "google_cloud_run_v2_service" "target" {
  name     = "scheduler-target"
  location = "europe-west2"
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  template {
    service_account = google_service_account.run_runtime.email
    timeout         = "300s"

    containers {
      image = "gcr.io/cloudrun/hello:1.0.0"

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
  }

  # Explicit project-level policy above enables Google's global vulnerability
  # policy under enforcement; default_admission_rule stays ALWAYS_ALLOW because
  # this demo image isn't signed by an attestor.
  binary_authorization {
    use_default = true
  }

  depends_on = [google_binary_authorization_policy.project]
}

resource "google_cloud_run_v2_service_iam_member" "scheduler_invoke" {
  name     = google_cloud_run_v2_service.target.name
  location = google_cloud_run_v2_service.target.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.scheduler_invoker.email}"
}

locals {
  job_name = "holden-test-job"
}

# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
# holden:ignore:HLD_TF_065: this repo exists to exercise holden's scheduler policies, so a single-resource wrapper module is the point, not an accident
module "scheduler" {
  source                = "../../"
  job_name              = local.job_name
  schedule              = "0 */6 * * *"
  uri                   = google_cloud_run_v2_service.target.uri
  service_account_email = google_service_account.scheduler_invoker.email
  region                = "europe-west2"
  description           = "Invokes scheduler-target every 6 hours"
  attempt_deadline      = "180s"

  depends_on = [
    google_cloud_run_v2_service_iam_member.scheduler_invoke
  ]
}