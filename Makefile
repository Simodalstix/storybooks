# Usage:
#   TF_ACTION=plan make terraform-action   # To preview changes
#   TF_ACTION=apply make terraform-action  # To deploy
#   TF_ACTION=destroy make terraform-action  # To tear down

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

# Define a function to retrieve a secret value from Google Secret Manager
define get-secret
  $(shell gcloud secrets versions access latest --secret=$(1) --project=$(PROJECT_ID) | tr -d '\n' | xargs)
endef

# Set your environment and project
ENV        ?= staging
TF_ACTION  ?= plan
PROJECT_ID ?= devops-mongo-storybooks

# Create a new Terraform workspace
terraform-create-workspace:
	cd terraform && \
	terraform workspace new $(ENV)

# Init Terraform in the correct workspace
terraform-init:
	cd terraform && \
	terraform workspace select $(ENV) && \
	terraform init

# Run a Terraform plan/apply with secrets from GCP
terraform-action:
	cd terraform && \
	terraform workspace select $(ENV) && \
	terraform $(TF_ACTION) \
	  -var-file="./environments/common.tfvars" \
	  -var-file="./environments/$(ENV)/config.tfvars" \

# SSH

SSH_STRING=simon@storybooks-vm-$(ENV)

VERSION ?= latest
LOCAL_TAG=storybooks-app:$(VERSION)
REMOTE_TAG=gcr.io/$(PROJECT_ID)/$(LOCAL_TAG)

ssh:
	gcloud compute ssh $(SSH_STRING) \
		--project=$(PROJECT_ID) \
		--zone=$(ZONE)

ssh-cmd:
	gcloud compute ssh $(SSH_STRING) \
		--project=$(PROJECT_ID) \
		--zone=$(ZONE) \
		--command="$(CMD)"

build:
	docker build -t $(LOCAL_TAG) .

push:
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)