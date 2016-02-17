defmodule CbEvSyslog.Rules.Filemod do
  import CbEvSyslog.Rules.Helper
  def init(x) do
    {:ok, 0}
  end

  def handle_event(event = %{event: %{filemod: filemod = %{action: :actionFileModLastWrite}}}, count) do
    event
    |> enrich_with_procstart
    |> enrich_header
    |> enrich_sensor
    |> enrich_filemod
    |> tee(CbEvSyslog.Rules.Resolved.Filemod)
    {:ok, count+1}
  end
  def handle_event(_, count) do
    {:ok, count}
  end


end
