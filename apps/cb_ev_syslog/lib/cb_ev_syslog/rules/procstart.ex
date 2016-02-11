require Logger
defmodule CbEvSyslog.Rules.Procstart do
  import CbEvSyslog.Rules.Helper
  def init(x) do
    {:ok, 0}
  end

  def handle_event(%CbEvSyslog.Dispatch{event: event = %{env: env, header: header, process: process}}, count) when is_map(process) do
    ## populate_process_cache(event)
    populate_process_cache(event)
#    event
#    |> enrich_header
#    |> enrich_process
#    |> :jsx.encode
#    |> to_syslog
    {:ok, count+1}
  end
end


