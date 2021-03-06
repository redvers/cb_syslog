defmodule CbEvSyslog.Rules.Procstart do
  import CbEvSyslog.Rules.Helper
  def init(x) do
    {:ok, 0}
  end

  def handle_event(event = %{env: env, header: header, process: process}, count) when is_map(process) do
    event
    |> enrich_header
    |> enrich_process
    |> :jsx.encode
    |> to_syslog
    {:ok, count+1}
  end
end


