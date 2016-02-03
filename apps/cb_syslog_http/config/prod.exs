use Mix.Config

config :cb_syslog_http, CbSyslogHttp.Endpoint,
  http: [port: 4000],
  url: [host: "notmycbserver.com", port: 4000],
  cache_static_manifest: "priv/static/manifest.json",
  debug_errors: false,
  code_reloader: false,
  server: true

config :logger, level: :info

import_config "prod.secret.exs"
