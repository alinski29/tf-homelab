datasources:
  postgres:
    url: jdbc:postgresql://${db_hostname}:${db_port}/kestra
    driverClassName: org.postgresql.Driver
    username: ${db_username}
    password: ${db_password}
kestra:
  server:
    basicAuth:
      enabled: false
      username: "admin@localhost.dev"
      password: kestra
  repository:
    type: postgres
  storage:
    type: local
    local:
      basePath: "/app/storage"
  queue:
    type: postgres
  tasks:
    tmpDir:
      path: /tmp/kestra-wd/tmp
  url: http://localhost:8080/
  anonymousUsageReport:
    enabled: false
  plugins:
    configurations:
      - type: io.kestra.plugin.scripts.runner.docker.Docker
        values:
          volume-enabled: true
