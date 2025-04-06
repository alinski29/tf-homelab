global:
  checkNewVersion: false
  sendAnonymousUsage: false

log:
  level: DEBUG

accessLog: {}

api:
  dashboard: true
  insecure: true

entryPoints:
  web:
    address: :80
    # http:
    #   redirections:
    #     entryPoint:
    #       to: websecure
    #       scheme: https
  websecure:
    address: :443

#certificatesResolvers:
#  le:
#    acme:
#      email: ${letsencrypt_email}
#      storage: /etc/traefik/certs/acme.json
#      httpChallenge:
#        # used during the challenge
#        entryPoint: web

#serversTransport:
#  insecureSkipVerify: true

http:
  routers:
    openwebui:
      rule: "Host(`ai.home.lan`)"
      service: openwebui
      entryPoints:
        - web

  services:
    openwebui:
      loadBalancer:
        servers:
          - url: http://192.168.0.29:3000

providers:
  docker:
    exposedByDefault: false
    endpoint: 'unix:///var/run/docker.sock'
    watch: true
    useBindPortIP: true
  file:
    directory: /etc/traefik
    watch: true
