defmodule CbEvSyslog.Rules.Netconn do
  import CbEvSyslog.Rules.Helper
  def init(x) do
    {:ok, 0}
  end

  def handle_event(event = %{env: env, header: header, network: network}, count) when is_map(network) do
    event
    |> enrich_header
    |> enrich_netconn
    |> :jsx.encode
    |> to_syslog
    {:ok, count + 1}
  end
end
