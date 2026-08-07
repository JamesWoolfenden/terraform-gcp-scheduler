output "job_id" {
  value       = module.scheduler.job_id
  description = "ID of the Cloud Scheduler job created by the module"
}

output "target_uri" {
  value       = google_cloud_run_v2_service.target.uri
  description = "URI of the Cloud Run service the scheduler job invokes"
}
