# Terraform Homelab Project

This project contains Terraform configurations to deploy various Docker services on a homelab setup. The services are deployed either on the localhost or a Raspberry Pi 4.

## Services Deployed
- Syncthing
- Pihole
- Jellyfin
- Qbittorrent
- Kestra
- Open WebUI
- OTEL Collector
- Prometheus
- Cadvisor (exports Docker metrics to Prometheus)
- Loki (like Prometheus but for logs)
- Tempo (distributed tracing backend)
- Grafana

## Prerequisites
1. Install [Terraform](https://www.terraform.io/downloads).
2. Ensure Docker is installed and running on both the localhost and Raspberry Pi.
3. Configure SSH access to the Raspberry Pi for file uploads and remote Docker management.
4. Set the following environment variables for sensitive data:
   ```bash
   export TF_VAR_pihole_webpassword="<your_pihole_password>"
   export TF_VAR_kestra_db_password="<your_kestra_db_password>"
   export TF_VAR_yahoofinance_token="<your_yahoofinance_token>"
   export TF_VAR_openai_api_key="<your_openai_api_key>"
   export TF_VAR_duckdns_api_token="<your_duckdns_api_token>"
   export TF_VAR_grafana_admin_password="<your_grafana_admin_password>"
   export TF_VAR_loki_otel_password="<your_loki_otel_password>"
   export TF_VAR_prometheus_otel_password="<your_prometheus_otel_password>"
   export TF_VAR_otel_receiver_password="<your_otel_receiver_password>"
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
