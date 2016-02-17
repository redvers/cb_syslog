require Logger
defmodule CbEvSyslog.Rules.Netconn do
  import CbEvSyslog.Rules.Helper
  def init(_) do
    {:ok, 0}
  end

  def handle_event(event = %{event: subevent = %{env: env, header: header, network: network}}, count) when is_map(network) do
    event
    |> enrich_with_procstart
    |> enrich_header
    |> enrich_sensor
    |> enrich_netconn
    |> tee(CbEvSyslog.Egress.Syslog)
    {:ok, count + 1}
  end
end
