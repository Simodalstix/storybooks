# Define your GCP Project ID
PROJECT_ID=devops-mongo-storybooks
BUCKET_NAME=$(PROJECT_ID)-terraform

# Run your local Docker Compose app
run-local:
	docker-compose up --build

# Shut down containers
stop:
	docker-compose down

# Create a GCS bucket for Terraform state
create-tf-backend-bucket:
	gsutil mb -p $(PROJECT_ID) -l australia-southeast1 gs://$(BUCKET_NAME)

# Optional: Enable versioning on the bucket
enable-versioning:
	gsutil versioning set on gs://$(BUCKET_NAME)

ENV=staging

terraform-create-workspace:
	cd terraform && \
		terraform workspace new $(ENV)

terraform-init:
	cd terraform && \
	terraform workspace select $(ENV) && \
	terraform init