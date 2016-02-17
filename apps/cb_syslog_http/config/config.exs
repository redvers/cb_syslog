# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :cb_syslog_http, CbSyslogHttp.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "xAXY0+LmvE089bJWIFZmg2E8cSSIgq9iQ235mRh1cv37frLFpDggprQGzt4/iKH8",
  render_errors: [accepts: ~w(html json)],
  server: true,
  pubsub: [name: CbSyslogHttp.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
