global:
  checkNewVersion: false
  sendAnonymousUsage: false

log:
  level: DEBUG

accessLog: {}

api:
  dashboard: true
  insecure: true

metrics:
  otlp:
    addEntryPointsLabels: true
    addRoutersLabels: true
    addServicesLabels: true
    pushInterval: 10s
    grpc:
      # endpoint: https://otel-grpc.${cert_domain}:443
      endpoint: otelcol:4317
      insecure: true

entryPoints:
  web:
    address: :80
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https

  websecure:
    address: :443
    http:
      tls:
        certResolver: duckdns
        domains:
          - main: "${cert_domain}"
            sans:
              - "*.${cert_domain}"

  syncthing-tcp:
    address: :22000

certificatesResolvers:
  duckdns:
    acme:
      email: "alinski29@github.com"
      storage: /etc/traefik/certs/duckdns-acme.json
      caServer: https://acme-v02.api.letsencrypt.org/directory
      # Use these for testing with Let's Encrypt staging server
      # storage: /etc/traefik/certs/duckdns-acme-staging.json
      # caServer: https://acme-staging-v02.api.letsencrypt.org/directory
      dnsChallenge:
        provider: duckdns
        delaybeforecheck: 20
        propagation:
          disableChecks: true
        resolvers:
          - "1.1.1.1:53"
          - "8.8.8.8:53"
          # Uncomment if there are issues with resolving the certificate
          # - "3.97.51.116:53"
          # - "99.79.16.64:53"
          # - "99.79.143.35:53"
          # - "35.182.183.211:53"
  # cloudflare:
  #   acme:
  #     email: ....
  #     storage: /etc/traefik/certs/cloudflare-acme.json
  #     caServer: https://acme-v02.api.letsencrypt.org/directory
  #     keyType: EC256
  #     dnsChallenge:
  #       provider: cloudflare
  #       resolvers:
  #         - "1.1.1.1:53"
  #         - "8.8.8.8:53"

serversTransport:
  insecureSkipVerify: false

http:
  routers:
  #   openwebui:
  #     rule: "Host(`ai.${cert_domain}`)"
  #     service: openwebui
  #     entryPoints:
  #       - web
  #     tls:
  #       certResolver: duckdns
  #       domains:
  #         - main: "${cert_domain}"
  #           sans:
  #             - "*.${cert_domain}"

    local-redirect:
      entryPoints:
        - web
        - websecure
      # Use HostRegexp with specific subdomains
      # rule: HostRegexp(`{subdomain:(media|kestra)}\.home\.lan`)
      rule: "Host(`ai.home.lan`) || Host(`traefik.home.lan`) || Host(`media.home.lan`) || Host(`kestra.home.lan`) || Host(`pihole.home.lan`) || Host(`torrents.home.lan`) || Host(`syncthing-pi.home.lan`)"
      middlewares:
        - redirect-home-to-duckdns
      service: noop@internal  # No backend service needed since it's a redirect

  middlewares:
    redirect-home-to-duckdns:
      redirectRegex:
        regex: "^(http|https)://([^.]+)\\.home\\.lan(.*)$"
        # Use group 2 (subdomain) and group 3 (path)
        replacement: "https://$2.${cert_domain}$3"
        permanent: true

    loki-auth:
      basicAuth:
        usersFile: /etc/traefik/auth/loki-users.txt

    prometheus-auth:
      basicAuth:
        usersFile: /etc/traefik/auth/prometheus-users.txt

    otel-auth:
      basicAuth:
        usersFile: /etc/traefik/auth/otel-users.txt

  # services:
  #   openwebui:
  #     loadBalancer:
  #       servers:
  #         - url: http://192.168.0.29:3000

providers:
  docker:
    exposedByDefault: false
    endpoint: 'unix:///var/run/docker.sock'
    watch: true
    useBindPortIP: true
  file:
    directory: /etc/traefik
    watch: true
