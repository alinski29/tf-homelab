variable "docker_volumes_home" {
  description = "Base path for Docker volumes on the target host."
  type        = string
  default     = "~/.local/share/docker/volumes"
}

variable "pi_home" {
  description = "Path to home directory for Raspery Pi server"
  type        = string
  default     = "/home/pi"
}

variable "pi_ip_address" {
  description = "IP address of the Raspberry Pi server."
  type        = string
  default     = "192.168.0.250"
}

variable "cert_domain" {
  description = "Domain name for the certificate."
  type        = string
  default     = "zendata.duckdns.org"
}

variable "local_home" {
  description = "Path to home directory for Raspery Pi server"
  type        = string
  default     = "/home/alinski"
}

variable "syncthing_image_tag" {
  description = "Docker tag for the syncthing image"
  type        = string
  default     = "latest"
}

variable "timezone" {
  description = "Timezone for containers."
  type        = string
  default     = "Europe/Bucharest"
}

variable "pihole_webpassword" {
  description = "Password for the Pi-hole web interface."
  type        = string
  sensitive   = true
  # No default, should be provided via environment variable TF_VAR_pihole_webpassword
}

variable "puid" {
  description = "User ID for container processes."
  type        = string
  default     = "1000"
}

variable "pgid" {
  description = "Group ID for container processes."
  type        = string
  default     = "1000" # Defaulting to 1000, adjust per service if needed (e.g., syncthing uses 100)
}

variable "kestra_db_username" {
  description = "Username for the Kestra Postgtres database"
  type        = string
  default     = "kestra"
}

variable "kestra_db_password" {
  description = "Password for the Kestra Postgres database."
  type        = string
  sensitive   = true
  # No default, should be provided via environment variable TF_VAR_kestra_password
}

variable "yahoofinance_token" {
  description = "Token for Yahoo Finance API."
  type        = string
  sensitive   = true
  # No default, should be provided via environment variable TF_VAR_yahoofinance_token
}

variable "openai_api_key" {
  description = "OpenAI API Key for Open WebUI."
  type        = string
  sensitive   = true
  # Provide via environment variable TF_VAR_openai_api_key
}

variable "openwebui_port" {
  description = "Port to expose Open WebUI on the host."
  type        = number
  default     = 3000
}


variable "anthropic_api_key" {
  description = "Anthropic API Key for Open WebUI."
  type        = string
  sensitive   = true
  # Provide via environment variable TF_VAR_anthropic_api_key
}


variable "google_api_key" {
  description = "Google API Key for Open WebUI."
  type        = string
  sensitive   = true
  # Provide via environment variable TF_VAR_google_api_key
}

# variable "cloudflare_email" {
#   description = "Email address for Cloudflare API."
#   type        = string
#   sensitive   = true
#   # No default, should be provided via environment variable TF_VAR_cloudflare_email
# }

# variable "cloudflare_api_token" {
#   description = "API key for Cloudflare."
#   type        = string
#   sensitive   = true
#   # No default, should be provided via environment variable TF_VAR_cloudflare_api_key
# }

variable "duckdns_api_token" {
  description = "API token for DuckDNS."
  type        = string
  sensitive   = true
  # No default, should be provided via environment variable TF_VAR_duckdns_api_token
}
