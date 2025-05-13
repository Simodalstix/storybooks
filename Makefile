# Set your environment and project
ENV         ?= staging
PROJECT_ID  ?= devops-mongo-storybooks
REGION      ?= australia-southeast1
ZONE        ?= australia-southeast1-b
REPO        ?= storybooks
BUCKET_NAME = $(PROJECT_ID)-terraform

LOCAL_TAG   = storybooks-app:latest
REMOTE_TAG  = $(REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPO)/storybooks-app:latest
CONTAINER_NAME = storybooks-$(ENV)

# MongoDB URI (no encoding needed for current password)
MONGO_USER     = storybooks-user-$(ENV)
MONGO_PASSWORD = ghfd5463gFG  # (can be overridden via shell or .env)
MONGO_CLUSTER  = storybooks-$(ENV).4w8vprp.mongodb.net
MONGO_APP_NAME = storybooks-$(ENV)

MONGO_URI = mongodb+srv://$(MONGO_USER):$(strip $(MONGO_PASSWORD))@$(MONGO_CLUSTER)/?retryWrites=true&w=majority&appName=$(MONGO_APP_NAME)

# Optional: GCS bucket for Terraform state
create-tf-backend-bucket:
	gsutil mb -p $(PROJECT_ID) -l $(REGION) gs://$(BUCKET_NAME)

enable-versioning:
	gsutil versioning set on gs://$(BUCKET_NAME)

# Terraform workflow
TF_ACTION ?= plan

terraform-create-workspace:
	cd terraform && terraform workspace new $(ENV)

terraform-init:
	cd terraform && terraform workspace select $(ENV) && terraform init

terraform-action:
	cd terraform && terraform workspace select $(ENV) && terraform $(TF_ACTION) \
		-var-file="./environments/common.tfvars" \
		-var-file="./environments/$(ENV)/config.tfvars"

# SSH
SSH_STRING = simon@storybooks-vm-$(ENV)

ssh:
	gcloud compute ssh $(SSH_STRING) --project=$(PROJECT_ID) --zone=$(ZONE)

ssh-cmd:
	gcloud compute ssh $(SSH_STRING) --project=$(PROJECT_ID) --zone=$(ZONE) --command="$(CMD)"

# Docker build and push
build:
	docker build -t $(LOCAL_TAG) .

push:
	docker tag $(LOCAL_TAG) $(REMOTE_TAG)
	docker push $(REMOTE_TAG)

# Deploy to GCE
deploy:
	$(MAKE) ssh-cmd CMD='docker-credential-gcr configure-docker'
	$(MAKE) ssh-cmd CMD='docker pull $(REMOTE_TAG)'
	-$(MAKE) ssh-cmd CMD='docker container stop $(CONTAINER_NAME)'
	-$(MAKE) ssh-cmd CMD='docker container rm $(CONTAINER_NAME)'
	$(MAKE) ssh-cmd CMD='\
		docker run -d --name=$(CONTAINER_NAME) \
		--restart=unless-stopped \
		-p 80:3000 \
		-e PORT=3000 \
		-e MONGO_URI="$(MONGO_URI)" \
		$(REMOTE_TAG)'

# Optional: Secret retrieval (disabled unless re-enabled later)
# define get-secret
#   $(shell gcloud secrets versions access latest --secret=$(1) --project=$(PROJECT_ID) | tr -d '\n' | xargs)
# endef
run-local:
	docker rm -f storybooks-local 2>/dev/null || true
	docker run -d \
	  --name storybooks-local \
	  -p 80:3000 \
	  -e MONGO_URI="$(MONGO_URI)" \
	  -e PORT=3000 \
	  $(LOCAL_TAG)
