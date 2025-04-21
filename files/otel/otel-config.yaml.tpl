receivers:
  otlp:
    protocols:
      grpc:
        endpoint: otelcol:4317
      http:
        endpoint: otelcol:4318

  prometheus/collector:
    config:
      scrape_configs:
        - job_name: 'otel-cadvisor-scrape'
          scrape_interval: 10s
          static_configs:
            - targets: ['${cadvisor_url}']

  hostmetrics:
    collection_interval: 30s
    scrapers:
      cpu:
      memory:
      disk:
      network:

  filelog:
    include_file_path: true
    # error_mode: drop
    include:
      - /var/lib/docker/containers/*/*-json.log
    operators:
      - id: container-parser
        type: container
        format: docker
        # severity: error
      - id: extract_metadata_from_docker_tag
        type: regex_parser
        regex: '^(?P<name>[^\|]+)\|(?P<container_id_short>[^\|]+)$'
        parse_from: attributes.attrs.tag
      - id: extract-container-id
        type: regex_parser
        regex: '^/var/lib/docker/containers/(?P<container_id>[^/]+)/'
        parse_from: attributes["log.file.path"]
      - type: move
        from: attributes.container_id
        to: resource["container.id"]
      - type: move
        from: attributes.name
        to: resource["container.name"]

processors:
  batch:

  filter/exclude_logs:
    error_mode: ignore
    # This drops logs that match the filter
    logs:
      log_record:
        - 'resource.attributes["container.name"] == "otelcol"'

  filter/errors_warnings:
    error_mode: ignore
    logs:
      log_record:
        - 'IsMatch(body, "level=(error|warn|fatal|critical)")'
        - 'resource.attributes["detected_level"] == "error"'

  filter/info_debug:
    error_mode: ignore
    logs:
      log_record:
        # - 'IsMatch(body, "level=(info|debug|trace)")'
        - 'resource.attributes["detected_level"] != "error"'

  probabilistic_sampler:
    sampling_percentage: 5

  transform/docker-logs:
    log_statements:
      - context: log
        statements:
         - delete_key(attributes, "log.file.path")
         - delete_key(attributes, "log.file.name")
         - delete_key(attributes, "attrs")
         - delete_key(attributes, "container_id_short")
      - context: resource # Operate on the resource
        statements:
          - set(attributes["detected_level"], "info") where attributes["detected_level"] == "unknown"
          - set(attributes["environment"], "production")
          - set(attributes["project"], "homelab")
          - set(attributes["hostname"], "${hostname}")
      # - statements:
        # - delete_key(scope.attributes, "container.name")
        # - set(scope.attributes["detected_level"], "info") where scope.attributes["detected_level"] == "unknown"

exporters:
  otlphttp/metrics:
    # endpoint: http://prometheus:9090/api/v1/otlp
    endpoint: ${prometheus_url}/api/v1/otlp
    headers:
      Authorization: "${prometheus_auth_header}"
    tls:
      insecure: true

  otlphttp/traces:
    endpoint: ${tempo_url}/otlp
    headers:
      Authorization: "${tempo_auth_header}"
    tls:
      insecure: true

  otlphttp/logs:
    endpoint: ${loki_url}/otlp
    headers:
      Authorization: "${loki_auth_header}"
    tls:
      insecure: true
      insecure_skip_verify: true

  debug/metrics:
    verbosity: detailed

  debug/traces:
    verbosity: detailed

  debug/logs:
    verbosity: detailed

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlphttp/traces]
      #exporters: [otlphttp/traces,debug/traces]
    metrics:
      receivers: [otlp, prometheus/collector, hostmetrics]
      processors: [batch]
      exporters: [otlphttp/metrics]
      #exporters: [otlphttp/metrics,debug/metrics]
    logs/errors:
      receivers: [otlp, filelog]
      processors: [transform/docker-logs, filter/exclude_logs,  filter/errors_warnings, batch]
      exporters: [otlphttp/logs]
    logs/sampled:
      receivers: [otlp, filelog]
      processors: [transform/docker-logs, filter/exclude_logs, filter/info_debug, probabilistic_sampler, batch]
      exporters: [otlphttp/logs]
