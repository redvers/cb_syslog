require Logger
defmodule CbEvSyslog.Rules.Resolved.Netconn do
  use GenEvent
  import CbEvSyslog.Rules.Helper

  def start_link do
    {:ok, pid} = GenEvent.start_link(name: __MODULE__)
    GenEvent.add_handler(pid, __MODULE__, 0)
    {:ok, pid}
  end

  def init(_) do
    {:ok, 0}
  end

  def handle_event(event, count) do
    cond do
      Regex.match?(~r/Server/, event.sensordecorate.os_environment_display_string) ->
        event |> tee(CbEvSyslog.Rules.Resolved.Srv.Netconn)
      Regex.match?(~r/Windows/, event.sensordecorate.os_environment_display_string) ->
        event |> tee(CbEvSyslog.Rules.Resolved.Wks.Netconn)
      true ->
        event |> tee(CbEvSyslog.Rules.Resolved.Unk.Netconn)
    end
    {:ok, count + 1}
  end
end
