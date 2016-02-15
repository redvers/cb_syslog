require Logger
defmodule CbEvSyslog.Rules.Procstart do
  import CbEvSyslog.Rules.Helper

  def handle_event(event = %CbEvSyslog.Dispatch{event: subevent = %{env: env, header: header, process: process}}, count) when is_map(process) do
    event
    |> populate_process_cache
    |> enrich_header
    |> enrich_sensor
    |> enrich_process
    |> tee(CbEvSyslog.Egress.Syslog)
    {:ok, count+1}
  end
end


