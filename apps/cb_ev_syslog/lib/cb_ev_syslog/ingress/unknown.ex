defmodule CbEvSyslog.Ingress.Unknown do
  use GenEvent

  def start_link do
    {:ok, pid} = GenEvent.start_link(name: __MODULE__)
    GenEvent.add_mon_handler(pid, __MODULE__, 0)
    {:ok, pid}
  end

  def handle_event(_, count) do
    {:ok, count+1}
  end

end
