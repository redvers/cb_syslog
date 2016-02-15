require Logger
defmodule CbEvSyslog.Rules.Helper do

  def tee(event = %{drop: true}, _) do
  end

  def tee(event, stream) do
    GenEvent.notify(stream, event)
    event
  end

  def init(x \\ 0) do
    {:ok, x}
  end





  def enrich_with_procstart(event = %{event: %{header: %{process_pid: :undefined}}}) do
    Map.put(event, :drop, true)
  end

  def enrich_with_procstart(event = %{event: subevent}) do
    case :ets.lookup(:proccache, {subevent.env.endpoint."SensorId", subevent.header.process_pid, subevent.header.process_create_time}) do
      []       ->   #Logger.debug("Cachemiss")
                    CbEvSyslog.Sensor.Worker.recv_newevent(subevent.env.endpoint."SensorId", subevent)
        Map.put(event, :drop, true)
        cachehit -> #Logger.debug("Cachehit: #{inspect(cachehit)}")
                    Map.put(event, :procdecorate, cachehit)
    end
  end

  def populate_process_cache(event = %{ drop: true}) do
    event # plonk
  end
  def populate_process_cache(event = %{
        drop: false,
        event: procstart = %{
          env: %{
            endpoint: %{
              SensorId: sensorid
            }
          },
          header: %{
            process_pid: process_pid,
            process_create_time: process_create_time
          }
        }
      }) do
                              ## Key: sensorid, pid, createtime - same as CB
                              key = {sensorid, process_pid, process_create_time}
                              value = %CbEvSyslog.Process{commandline:        procstart.process.commandline,
                                        parent_md5:         procstart.process.parent_md5,
                                        parent_guid:        {sensorid, procstart.process.parent_pid, procstart.process.parent_create_time},
                                        parent_path:        procstart.process.parent_path,
                                        utf8string:        procstart.process.parent_path,
                                        uid:                procstart.process.uid,
                                        username:           procstart.process.username}
#                              Logger.debug("Writing to ets: #{inspect(value.parent_guid)}")
                              :ets.insert(:proccache, {key, value})
        event
      end
  def populate_process_cache(event = %{ drop: false, event: 
    %{env: %{endpoint: %{"SensorId": sensorid}},
      header: %{process_create_time: process_create_time, process_pid: process_pid },
      process: %{parent_create_time: parent_create_time, parent_pid: parent_pid, parent_md5: parent_md5,
                    parent_path: parent_path, commandline: commandline, uid: uid, username: username},
      strings: [%{utf8string: utf8string}]
            }}) do
    cachedata = %CbEvSyslog.Process{
      commandline: commandline,
      parent_guid: {sensorid, parent_pid, parent_create_time},
      parent_md5: parent_md5,
      parent_path: parent_path,
      uid: uid,
      username: username,
      utf8string: utf8string
    }

#    Logger.debug("Writing to ets2: #{inspect(cachedata.parent_guid)}")
    :ets.insert(:proccache, {{sensorid, process_pid, process_create_time}, cachedata})
    event
  end

  def depopulate_process_cache(event =
    %{env: %{endpoint: %{"SensorId": sensorid}},
      header: %{process_create_time: process_create_time, process_pid: process_pid }}) do
    :ets.delete(:proccache, {sensorid, process_pid, process_create_time})
  end


  def enrich_sensor(event = %{drop: true}) do
    event
  end
  def enrich_sensor(event) do
    sensordata = CbEvSyslog.DB.Sensor.read!(event.event.env.endpoint."SensorId")
    newevent = Map.put(event, :sensordecorate, sensordata)
    newevent
  end
  def enrich_header(event = %{drop: true}) do
    event
  end
  def enrich_header(event = %{event: subevent}) do
    newsubevent = subevent
    |> put_in([:header, :process_md5], process_md5(subevent.header.process_md5))
    |> put_in([:header, :process_guid], guid(subevent))
    |> put_in([:header, :timestamp], timestamp(subevent))
    Map.put(event, :event, newsubevent)
  end

  def enrich_filemod(event = %{drop: true}) do
    event
  end
  def enrich_filemod(event = %{event: subevent}) do
    newsubevent = subevent
    |> put_in([:filemod, :md5hash], process_md5(subevent.filemod.md5hash))
    Map.put(event, :event, newsubevent)
  end

  def enrich_process(event = %{drop: true}) do
    event
  end
  def enrich_process(event = %{drop: false, event: subevent}) do
    newsubevent = subevent
    |> put_in([:process, :md5hash], process_md5(subevent.process.md5hash))
    |> put_in([:process, :parent_md5], process_md5(subevent.process.parent_md5))
    |> put_in([:process, :parent_guid], guid(%{header: %{process_create_time: subevent.process.parent_create_time, process_pid: subevent.process.parent_pid}, env: %{endpoint: %{"SensorId": subevent.env.endpoint."SensorId"}}}))

#    Logger.debug("Another possible location - put_in #{inspect(newsubevent)}")
    Map.put(event, :event, newsubevent)
  end

  def enrich_netconn(event = %{drop: true}) do
    event
  end



  def enrich_netconn(event = %{event: subevent}) do
    newsubevent = subevent
    |> put_in([:network, :ipv4Address],      format_ipaddr(subevent.network.ipv4Address))
    |> put_in([:network, :localIpAddress],   format_ipaddr(subevent.network.localIpAddress))
    |> put_in([:network, :remoteIpAddress],  format_ipaddr(subevent.network.remoteIpAddress))
    |> put_in([:network, :proxyIpv4Address], format_ipaddr(subevent.network.proxyIpv4Address))
    |> put_in([:network, :port],             format_port(subevent.network.port))
    |> put_in([:network, :localPort],        format_port(subevent.network.localPort))
    |> put_in([:network, :remotePort],       format_port(subevent.network.remotePort))
    |> put_in([:network, :proxyPort],        format_port(subevent.network.proxyPort))
    |> put_in([:network, :protocol],         format_protocol(subevent.network.protocol))
    |> put_in([:network, :fqdnsplit],        split_fqdn(subevent.network.utf8_netpath))
    Map.put(event, :event, newsubevent)
  end

  def format_protocol(:ProtoTcp), do: "tcp" 
  def format_protocol(:ProtoUdp), do: "udp" 
  def format_protocol(other), do: to_string(other)



  def split_fqdn(:undefined) do
    %{host: "", domain: ""}
  end

  def split_fqdn(utf8_netpath) do
    String.downcase(utf8_netpath)
    |> String.split(".")
    |> assign_fqdn_split
  end

  def assign_fqdn_split([hostname]) do
    %{host: hostname, domain: ""}
  end
  def assign_fqdn_split([a,b]) do
    %{host: "", domain: "#{a}.#{b}"}
  end

  def assign_fqdn_split([h|t]) do
    %{host: h, domain: Enum.join(t, ".")}
  end


  def guid({0,0,0}) do
    "00000000-0000-0000-0000-000000000000"
  end
  def guid({sensorid, process_pid, process_create_time}) do
    << guid :: size(128) >> = << sensorid :: size(32), process_pid :: size(32), process_create_time :: size(64) >>
    :io_lib.format('~32.16.0b', [guid])
      |> List.flatten
      |> List.insert_at(8, '-')
      |> List.insert_at(13, '-')
      |> List.insert_at(18, '-')
      |> List.insert_at(23, '-')
      |> to_string
  end



  def guid(event = %{header: %{process_pid: :undefined}}) do 
    "00000000-0000-0000-0000-000000000000"
  end

  def guid(%{header: %{process_create_time: process_create_time, process_pid: process_pid}, 
             env: %{endpoint: %{"SensorId": sensorid}}}) do
    << guid :: size(128) >> = << sensorid :: size(32), process_pid :: size(32), process_create_time :: size(64) >>
    :io_lib.format('~32.16.0b', [guid])
      |> List.flatten
      |> List.insert_at(8, '-')
      |> List.insert_at(13, '-')
      |> List.insert_at(18, '-')
      |> List.insert_at(23, '-')
      |> to_string
  end

  def to_syslog(string) when is_binary(string) do
    GenEvent.notify(CbEvSyslog.Egress.Syslog, :unicode.characters_to_binary(string, :latin1))
  end

  def sensorhostname(%{env: %{endpoint: %{"SensorHostName": hostname}}}) do
    hostname |> to_string
  end

  def sensorid(%{env: %{endpoint: %{"SensorId": sensorid}}}) do
    sensorid |> to_string
  end

  def timestamp(%{header: %{timestamp: timestamp}}) do
    {{year,month,day},{hour,min,sec}} = round(timestamp / 10000000) + 50522745600 |> :calendar.gregorian_seconds_to_datetime
    :io_lib.format('~4..0B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0BZ', [year,month,day,hour,min,sec]) |> to_string
  end

  def process_md5(value) when is_binary(value) do
    value |> Base.encode16 |> String.downcase
  end

  def process_md5(:undefined) do
    "00000000000000000000000000000000"
  end


  def process_md5(%{header: %{process_md5: :undefined}}) do
    "00000000000000000000000000000000"
  end

  def process_md5(%{header: %{process_md5: process_md5}}) do
    process_md5 |> Base.encode16 |> String.downcase
  end

  def process_path(%{header: %{process_path: process_path}}) do
    process_path |> to_string
  end

  def format_ipaddr(:undefined) do
    "255.255.255.255"
  end
  def format_ipaddr(ip) do
    << a :: size(8), b :: size(8), c :: size(8), d :: size(8) >> = << ip :: little-size(32) >>
    "#{a}.#{b}.#{c}.#{d}"
  end

  def format_port(:undefined) do
    "0"
  end
  def format_port(port) do
    << a :: big-size(16) >> = << port :: little-size(16) >>
    a |> to_string
  end

  def filemod_string(%{strings: [%{utf8string: utf8string}]}) do
    utf8string
  end

  def filemod_md5(%{filemod: %{md5hash: :undefined}}) do
    "0000000000000000000000000000000"
  end
  def filemod_md5(%{filemod: %{md5hash: md5hash}}) do
    md5hash |> Base.encode16 |> String.downcase
  end




end

