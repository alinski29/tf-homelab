# Terraform Homelab Project

This project contains Terraform configurations to deploy various Docker services on a homelab setup. The services are deployed either on the localhost or a Raspberry Pi 4.

## Services Deployed
- Syncthing
- Pi-hole
- Plex
- Transmission
- Kestra
- Open WebUI

## Prerequisites
1. Install [Terraform](https://www.terraform.io/downloads).
2. Ensure Docker is installed and running on both the localhost and Raspberry Pi.
3. Configure SSH access to the Raspberry Pi for file uploads and remote Docker management.
4. Set the following environment variables for sensitive data:
   ```bash
   export TF_VAR_pihole_webpassword="<your_pihole_password>"
   export TF_VAR_kestra_db_password="<your_kestra_db_password>"
   export TF_VAR_yahoofinance_token="<your_yahoofinance_token>"
   export TF_VAR_transmission_username="<your_transmission_username>"
   export TF_VAR_transmission_password="<your_transmission_password>"
   export TF_VAR_openai_api_key="<your_openai_api_key>"
   ```

## Setup Instructions

### Initialize Terraform
Run the following command to initialize the Terraform working directory:
```bash
terraform init
```

### Plan the Deployment
Generate and review the execution plan to ensure the configuration is correct:
```bash
terraform plan
```

### Apply the Configuration
Apply the Terraform configuration to deploy the services:
```bash
terraform apply
```

### Destroy the Deployment
To remove all deployed resources, run:
```bash
terraform destroy
```
