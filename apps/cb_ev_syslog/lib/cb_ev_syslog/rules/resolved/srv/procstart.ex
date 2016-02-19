require Logger
defmodule CbEvSyslog.Rules.Resolved.Srv.Procstart do
  import CbEvSyslog.Rules.Helper
  use GenEvent

  def start_link do
    {:ok, pid} = GenEvent.start_link(name: __MODULE__)
    GenEvent.add_mon_handler(pid, __MODULE__, 0)
    {:ok, pid}
  end

  def init(_) do
    {:ok, 0}
  end

  def handle_event(event, count) do
    event |> tee(CbEvSyslog.Egress.Syslog)
    {:ok, count+1}
  end

end


