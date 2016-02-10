require Logger
defmodule CbEvSyslog.Process.Worker do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, [])
  end

  def init(state) do
    {:ok, []}
  end

  def handle_cast({:ev, ev}, state) do
    fifteenago = (:erlang.universaltime_to_posixtime(:erlang.universaltime) - (10 * 60))
    case (timestamp_to_unixtime(ev.header.process_create_time) > fifteenago) do
           true -> Logger.debug("Within the last 15m")
          false -> Logger.debug("Older than 15m")
    end




    {:noreply, [ev | state]}
  end

  def timestamp_to_unixtime(timestamp) do
    round(timestamp / 10000000) + 50522745600
    |> :calendar.gregorian_seconds_to_datetime
    |> :erlang.universaltime_to_posixtime
  end
end

