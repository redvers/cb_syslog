defmodule CbEvSyslog.Egress.Syslog do
  use GenEvent

  def start_link do
    {:ok, pid} = GenEvent.start_link(name: __MODULE__)
#    GenEvent.add_handler(pid, __MODULE__, 0)
    {:ok, pid}
  end

  def init(0) do
    {:ok, port} = :syslog.open('cbevsyslog', [:cons, :perror, :pid], :local0)
    {:ok, %{port: port, count: 0}}
  end

  def handle_event(txt, %{port: port, count: count}) do
    latin1 = :unicode.characters_to_binary(txt, :latin1)
    :syslog.log(port, :err, String.to_char_list(latin1))
    {:ok, %{port: port, count: count+1}}
  end

end
