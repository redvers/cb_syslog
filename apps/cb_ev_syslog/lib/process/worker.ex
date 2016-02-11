require Logger
defmodule CbEvSyslog.Process.Worker do
  @waittime 900000
  @norepeat 300000
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, [])
  end

  def init(state) do
    {:ok, %{queue: [], last_check: nil}}
  end

  def handle_cast({:ev, ev}, %{queue: q, last_check: lastcheck}) do
    fifteenago = (:erlang.universaltime_to_posixtime(:erlang.universaltime) - (10 * 60))
#    Logger.debug("Event timestamp: #{inspect(timestamp_to_unixtime(ev.header.process_create_time))}")
#    Logger.debug("Fifteenago: #{fifteenago}")
    case (timestamp_to_unixtime(ev.header.process_create_time) > fifteenago) do
       true -> :erlang.send_after(900000, self, :selflookup)
         #Logger.debug("Within the last 15m - setting timer")
         :ok
      false -> send(self, :selflookup)
         :ok
    end
    {:noreply, %{queue: [ev | q], last_check: lastcheck}}
  end




  def handle_info(:selflookup, state = %{queue: q, last_check: nil}) do
    #Logger.debug(inspect(self) <> "Lastcheck is nil, checking...")
    t = hd(q) 
    guidtuple = {t.env.endpoint."SensorId", t.header.process_pid, t.header.process_create_time}
    case :ets.member(:proccache, guidtuple) do
      true -> ##Logger.debug(inspect(self) <> "Lastcheck was nil, data is in ets. Empty queue of #{inspect(Enum.count(q))} events and die")
              empty_queue(state)
              {:stop, :normal, %{}}
      false ->
              #Logger.debug(inspect(self) <> "Lastcheck was nil, data is NOT in ets... running resolve process")
              #Logger.debug(inspect(guidtuple))
              case resolve_process(guidtuple) do
                :found -> #Logger.debug("Lastcheck was nil, data is NOT in ets, webui returned data")
                          send(self, :selflookup)
                          {:noreply, state}
                 :lost -> :erlang.send_after(@waittime, self, :self_lookup)
                          #Logger.debug("Lastcheck was nil, data was NOT in ets, webui returned NO data")
                          {:noreply, %{queue: q, last_check: :calendar.universal_time |> :calendar.datetime_to_gregorian_seconds }}
              end
    end
  end

  def handle_info(:selflookup, state = %{last_check: lastcheck}) do
    current_time = :calendar.universal_time |> :calendar.datetime_to_gregorian_seconds
    difference = current_time - lastcheck

    case (difference > @waittime) do
      true -> send(self, :selflookup)
              #Logger.debug("Lastcheck is set.  Age is: #{difference} which is > @waittime")
              {:noreply, Map.put(state, :last_check, nil)}
      false -> :erlang.send_after(@norepeat, self, :selflookup)
              #Logger.debug("Lastcheck is set.  Age is :#{difference} which is <= @waittime. Set timer for @norepeat")
              {:noreply, state}
    end
  end

  def empty_queue(%{queue: q}) do
    Enum.map(q, &dispatch/1)
#    Enum.map(q, &IO.inspect/1)
  end

  def dispatch(event = %{filemod: filemod}) when is_map(filemod), do: GenEvent.notify(CbEvSyslog.Ingress.Filemod, %CbEvSyslog.Dispatch{event: event, type: :filemod}) 
  def dispatch(event = %{network: netconn}) when is_map(netconn), do: GenEvent.notify(CbEvSyslog.Ingress.Netconn, %CbEvSyslog.Dispatch{event: event, type: :netconn}) 


  def resolve_process({sensorid, pid, createtime}) do
    << bguid :: size(128) >> = << sensorid :: size(32), pid :: size(32), createtime :: size(64) >>
    guid = :io_lib.format('~32.16.0b', [bguid])
    |> List.flatten
    |> List.insert_at(8, '-')
    |> List.insert_at(13, '-')
    |> List.insert_at(18, '-')
    |> List.insert_at(23, '-')
    |> to_string

#    Logger.debug("resolve_process guid maps to: #{guid}")

    %{"#cbclientapitoken" => token, "#cbclientapiurl" => url} = CbEvSyslog.Creds.webcreds
    {:ok, statuscode, _headers, reference} =
    :hackney.get("#{url}/v1/process?q=process_id:#{guid}&rows=1", [{"X-Auth-Token", token}], '', [ssl_options: [insecure: true], async: false])
    case statuscode do
      200 -> {:ok, body} = :hackney.body(reference)
             case :jsx.decode(body) |> jsx_into_process_struct do
               nil -> #Logger.debug("Nothing found in UI - try again later")
                      :lost
               procstruct -> #Logger.debug("procstruct generated: #{inspect(procstruct)}")
                             :ets.insert(:proccache, {procstruct.guid, procstruct})
                             :found
             end
      whatisthis   -> #Logger.debug("Got something other than a 200 #{inspect(whatisthis)}")
             :lost
    end
  end

  def jsx_into_process_struct(ds) do
    procd = Enum.into(ds, Map.new)
    |> Map.get("results")
    |> Enum.at(0)

    case procd do
      nil -> nil
      _   -> procdata = Enum.into(procd, Map.new)
             %CbEvSyslog.Process{commandline: Map.get(procdata, "cmdline"),
                        guid: uniqueid_to_tuple(Map.get(procdata, "unique_id")),
                        parent_guid: uniqueid_to_tuple(Map.get(procdata, :parent_unique_id)),
                        parent_md5: md5string_to_binary(Map.get(procdata, :parent_md5, "000000000000000000000000000000")),
                        parent_path: Map.get(procdata, "path", "unknown"),
                        uid:         Map.get(procdata, "uid", "unknown"),
                        username:    Map.get(procdata, "username", "unknown"),
                        utf8string:  Map.get(procdata, "path", "unknown")}
    end
  end

  def uniqueid_to_tuple(nil) do
    {0,0,0}
  end
  #0000096d-0000-0c94-01d1-63f5b087c4d3-0
  def uniqueid_to_tuple(uniqueid) do
#    IO.inspect uniqueid
    [a,b,c,d,e,f] = String.split(uniqueid, "-")
    guidbitstring = String.upcase(a <> b <> c <> d <> e) |> Base.decode16!
    << sensorid :: size(32), process_pid :: size(32), process_create_time :: size(64) >> = guidbitstring
    {sensorid, process_pid, process_create_time}
  end

  def md5string_to_binary(str) do
    String.upcase(str) |> Base.decode16!
  end






  def timestamp_to_unixtime(timestamp) do
    round(timestamp / 10000000) + 50522745600
    |> :calendar.gregorian_seconds_to_datetime
    |> :erlang.universaltime_to_posixtime
  end
end

