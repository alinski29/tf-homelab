locals {
  pi_docker_volumes_home      = replace(var.docker_volumes_home, "~/", "${var.pi_home}/")
  local_docker_volumes_home   = replace(var.docker_volumes_home, "~/", "${var.local_home}/")
  loki_otel_auth_header       = "Basic ${base64encode("monitoring:${var.loki_otel_password}")}"
  prometheus_otel_auth_header = "Basic ${base64encode("monitoring:${var.prometheus_otel_password}")}"
  otel_receiver_auth_header   = "Basic ${base64encode("monitoring:${var.otel_receiver_password}")}"
  tempo_otel_auth_header      = "Basic ${base64encode("monitoring:${var.tempo_otel_password}")}"
}
