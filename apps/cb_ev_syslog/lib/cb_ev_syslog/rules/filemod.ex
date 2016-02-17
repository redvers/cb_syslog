defmodule CbEvSyslog.Rules.Filemod do
  import CbEvSyslog.Rules.Helper
  def init(x) do
    {:ok, %{finalwrite: 0, dropped: 0}}
  end

  def handle_event(event = %{event: %{filemod: filemod = %{action: :actionFileModLastWrite}}}, %{finalwrite: c1, dropped: c2}) do
    event
    |> enrich_with_procstart
    |> enrich_header
    |> enrich_sensor
    |> enrich_filemod
    |> tee(CbEvSyslog.Rules.Resolved.Filemod)
    {:ok, %{finalwrite: c1 + 1,  dropped: c2}}
  end
  def handle_event(_, %{finalwrite: c1, dropped: c2}) do
    {:ok, %{finalwrite: c1, dropped:  c2+1}}
  end


end
