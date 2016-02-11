require Logger
defmodule CbEvSyslog.Rules.Netconn do
  import CbEvSyslog.Rules.Helper
  def init(x) do
    {:ok, 0}
  end

  def handle_event(event = %{event: subevent = %{env: env, header: header, network: network}}, count) when is_map(network) do
#    Logger.debug(inspect(event))
    event
    |> enrich_with_procstart
#    |> enrich_header
#    |> enrich_netconn
#    |> :jsx.encode
#    |> to_syslog
    {:ok, count + 1}
  end
end
