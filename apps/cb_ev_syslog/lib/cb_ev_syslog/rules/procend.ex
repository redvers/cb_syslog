require Logger
defmodule CbEvSyslog.Rules.Procend do
  import CbEvSyslog.Rules.Helper
  def init(_) do
    {:ok, 0}
  end

  def handle_event(%CbEvSyslog.Dispatch{event: event = %{env: env, header: header, process: process}}, count) when is_map(process) do
    depopulate_process_cache(event)
    {:ok, count+1}
  end
end


