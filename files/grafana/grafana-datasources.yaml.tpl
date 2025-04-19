apiVersion: 1

datasources:
%{ if prometheus_url != "" }
  - name: Prometheus
    type: prometheus
    uid: prometheus
    url: ${prometheus_url}
    editable: true
    jsonData:
      timeInterval: 60s
      exemplarTraceIdDestinations:
        - name: trace_id
          datasourceUid: tempo
          urlDisplayLabel: "Trace: $${__value.raw}"
%{ endif }

%{ if tempo_url != "" }
  - name: Tempo
    type: tempo
    uid: tempo
    url: ${tempo_url}
    editable: true
    jsonData:
      tracesToLogsV2:
        customQuery: true
        datasourceUid: "loki"
        query: '{$${__tags}} | trace_id = "$${__trace.traceId}"'
        tags:
          - key: "service.name"
            value: "service_name"

      serviceMap:
        datasourceUid: "prometheus"
      search:
        hide: false
      nodeGraph:
        enabled: true
      lokiSearch:
        datasourceUid: "loki"
%{ endif }

%{ if loki_url != "" }
  - name: Loki
    type: loki
    uid: loki
    url: ${loki_url}
    editable: true
    jsonData:
      derivedFields:
        - name: "trace_id"
          matcherType: "label"
          matcherRegex: "trace_id"
          url: "$${__value.raw}"
          datasourceUid: "tempo"
          urlDisplayLabel: "Trace: $${__value.raw}"
%{ endif }

%{ if pyroscope_url != "" }
  - name: Pyroscope
    type: grafana-pyroscope-datasource
    uid: pyroscope
    url: ${pyroscope_url}
%{ endif }
