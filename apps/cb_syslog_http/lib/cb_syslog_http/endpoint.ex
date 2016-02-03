defmodule CbSyslogHttp.Endpoint do
  use Phoenix.Endpoint, otp_app: :cb_syslog_http

  socket "/socket", CbSyslogHttp.UserSocket
  plug Plug.Static,
    at: "/", from: :cb_syslog_http, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_cb_syslog_http_key",
    signing_salt: "8az1Jp1D"

  plug CbSyslogHttp.Router
end
