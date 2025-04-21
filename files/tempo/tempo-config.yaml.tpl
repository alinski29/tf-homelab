server:
  http_listen_port: 3200
  grpc_listen_port: 9096

distributor:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4417
        http:
          endpoint: 0.0.0.0:4418

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    min_ready_duration: 1s

storage:
  trace:
    backend: local
    wal:
      path: /data/tempo/wal
    local:
      path: /data/tempo/blocks

metrics_generator:
  processor:
    local_blocks:
      filter_server_spans: false
    span_metrics:
      dimensions:
        - service_name
        - operation
        - status_code
  traces_storage:
    path: /data/tempo/generator/traces
  storage:
    path: /data/tempo/generator/wal
    remote_write:
      - url: ${prometheus_endpoint}
        send_exemplars: true
        basic_auth:
          username: "${prometheus_username}"
          password: "${prometheus_password}"

overrides:
  metrics_generator_processors: [service-graphs, local-blocks, span-metrics]
