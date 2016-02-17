defmodule CbEvSyslog.StatsGen do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(%{}) do
    :erlang.send_after(1000, self, :ping)
    {:ok, %{stats: %{}}}
  end

  def handle_info(:ping, state) do
    modules = [CbEvSyslog.Ingress.Procstart,
               CbEvSyslog.Ingress.Procend, 
               CbEvSyslog.Ingress.Childproc, 
               CbEvSyslog.Ingress.Moduleload, 
               CbEvSyslog.Ingress.Module, 
               CbEvSyslog.Ingress.Filemod, 
               CbEvSyslog.Ingress.Regmod, 
               CbEvSyslog.Ingress.Netconn, 
               CbEvSyslog.Ingress.Unknown, 
               CbEvSyslog.Egress.Syslog]

    newstate = Enum.reduce(modules, %{}, fn(module, acc) -> cur = base_counter(module) |> total_counts
                                               mabv = Atom.to_string(module) |> String.split(".") |> Enum.at(-1)
                                               orig = Map.get(state, mabv, 0)
                                               diff = cur - orig

                                               currdiff = Map.get(acc, :stats, %{})
                                               |> Map.put(mabv, diff)

                                               Map.put(acc, mabv, cur)
                                               |> Map.put(:stats, currdiff) end)
    CbSyslogHttp.Endpoint.broadcast!("rooms:lobby", "new_msg", state.stats)

    :erlang.send_after(1000, self, :ping)
    {:noreply, newstate}
  end

  def total_counts(%{port: _, count: count}) do
    count
  end

  def total_counts(%{dropped: dropped, finalwrite: finalwrite}) do
    dropped + finalwrite
  end

  def total_counts(num) do
    num
  end

  def base_counter(module) do
    :sys.get_state(module)
    |> Enum.filter(&is_self/1)
    |> Enum.at(0)
    |> Tuple.to_list
    |> Enum.at(2)
  end

  def is_self({module, module, _}) do
    true
  end
  def is_self({_,_,_}) do
    false
  end


end
