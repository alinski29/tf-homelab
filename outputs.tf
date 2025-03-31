output "syncthing_pi_container_id" {
  value = docker_container.syncthing_pi.id
}

output "syncthing_pi_container_started" {
  value = docker_container.syncthing_pi.start
}

output "syncthing_pi_container_exit_code" {
  value = docker_container.syncthing_pi.exit_code
}

output "syncthing_local_container_id" {
  value = docker_container.syncthing_local.id
}

output "syncthing_local_container_started" {
  value = docker_container.syncthing_local.start
}

output "syncthing_local_container_exit_code" {
  value = docker_container.syncthing_local.exit_code
}


output "pihole_local_container_id" {
  value = docker_container.pihole.id
}

output "pihole_local_container_started" {
  value = docker_container.pihole.start
}

output "pihole_local_container_exit_code" {
  value = docker_container.pihole.exit_code
}

output "kestra_container_id" {
  value = docker_container.kestra.id
}

output "kestra_container_started" {
  value = docker_container.kestra.start
}

output "kestra_container_exit_code" {
  value = docker_container.kestra.exit_code
}

output "kestra_postgres_container_id" {
  value = docker_container.kestra_postgres.id
}

output "kestra_postgres_container_started" {
  value = docker_container.kestra_postgres.start
}

output "kestra_postgres_container_exit_code" {
  value = docker_container.kestra_postgres.exit_code
}

output "ollama_container_id" {
  value = docker_container.ollama.id
}

output "ollama_container_started" {
  value = docker_container.ollama.start
}

output "ollama_container_exit_code" {
  value = docker_container.ollama.exit_code
}

output "openwebui_container_id" {
  value = docker_container.openwebui.id
}

output "openwebui_container_started" {
  value = docker_container.openwebui.start
}

output "openwebui_container_exit_code" {
  value = docker_container.openwebui.exit_code
}
