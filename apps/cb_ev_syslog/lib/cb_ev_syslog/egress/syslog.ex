require Logger
defmodule CbEvSyslog.Egress.Syslog do
  import CbEvSyslog.Rules.Helper
  use GenEvent

  def start_link do
    {:ok, pid} = GenEvent.start_link(name: __MODULE__)
    GenEvent.add_handler(pid, __MODULE__, 0)
    {:ok, pid}
  end

  def init(0) do
    {:ok, port} = :syslog.open('cbevsyslog', [:cons, :perror, :pid], :local0)
    {:ok, %{port: port, count: 0}}
  end

  def txt2syslog(txt, port) do
    latin1 = :unicode.characters_to_binary(txt, :latin1)
    :syslog.log(port, :err, String.to_char_list(latin1))
  end

  def handle_event(%{drop: true}, %{port: port, count: count}) do
    {:ok, %{port: port, count: count+1}}
  end

  def handle_event(event = %{drop: false, event: subevent, sensordecorate: sd, procdecorate: pd}, %{port: port, count: count}) do
    nevent = event
    |> Map.put(:sensordecorate, mfs(sd))
    |> Map.put(:procdecorate,   mfs(pd))
    |> Map.from_struct
    |> rewrite_procdecorate
    |> rewrite_sensordecorate
    |> :jsx.encode
    
    nevent
    |> txt2syslog(port)
    {:ok, %{port: port, count: count+1}}
  end

  def mfs(nil) do
    nil
  end
  def mfs([{_, map}]) do
    Map.from_struct(map)
  end
  def mfs(map) do
    Map.from_struct(map)
  end

  def rewrite_sensordecorate(event = %{sensordecorate: nil}) do
    event
  end
  def rewrite_sensordecorate(event = %{sensordecorate: sensordecorate}) do
     networks = split_network(sensordecorate.network_adapters)
    newsd = Map.put(sensordecorate, :networks, networks)
    Map.put(event, :sensordecorate, newsd)
  end

  def split_network(str) when is_binary(str) do
    String.split(str, "|")
    |> Enum.map(&process_n/1)
    |> Enum.reject(&(&1 == nil))
  end
  def split_network(str) do
    [%{ip: "0.0.0.0", mac: "000000000000"}]
  end

  def process_n("") do
    nil
  end

  def process_n(string) do
    [ip, mac] = String.split(string, ",")
    %{ip: ip, mac: mac}
  end






  def rewrite_procdecorate(event = %{procdecorate: nil}) do
    event
  end
  def rewrite_procdecorate(event = %{procdecorate: procdecorate}) do
#    IO.inspect(procdecorate)
    newpd = put_in(procdecorate, [:guid], guid(procdecorate.guid))
        |>  put_in([:parent_guid], guid(procdecorate.parent_guid))
        |>  put_in([:parent_md5], process_md5(procdecorate.parent_md5))
    Map.put(event, :procdecorate, newpd)
  end


end
