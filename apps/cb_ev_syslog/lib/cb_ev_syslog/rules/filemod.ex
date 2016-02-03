defmodule CbEvSyslog.Rules.Filemod do
  import CbEvSyslog.Rules.Helper
  def init(x) do
    {:ok, %{finalwrite: 0, dropped: 0}}
  end

  ## This function only executes when Filemods are of type :actionFileModLastWrite
  def handle_event(event = %{filemod: filemod = %{action: :actionFileModLastWrite}}, %{finalwrite: c1, dropped: c2}) do
    event
    |> enrich_header
    |> enrich_filemod
    |> :jsx.encode
    |> to_syslog
    {:ok, %{finalwrite: c1 + 1,  dropped: c2}}
  end

  ## This function executes on any non-matched above. We increase the drop counter and move on with our lives.
  def handle_event(_, %{finalwrite: c1, dropped: c2}) do
    {:ok, %{finalwrite: c1, dropped:  c2+1}}
  end

  

end
