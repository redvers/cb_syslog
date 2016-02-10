require Logger
defmodule CbEvSyslog.Sensor do
  defstruct sensor: %{}, processmap: %{}
end

defmodule CbEvSyslog.Sensor.Worker do
  use GenServer

  def recv_newevent(sensorid, event) do
    new_sensor(sensorid)
    |> GenServer.cast({:newevent, event})
  end

  def new_sensor(sensorid) do
    case :gproc.lookup_local_name({:sensor, sensorid}) do
      :undefined -> {:ok, pid} = Supervisor.start_child(CbEvSyslog.Sensor.Supervisor, [sensorid])
                    pid
      pid -> pid
    end
    pid = :gproc.lookup_local_name({:sensor, sensorid})
  end











  def handle_cast({:newevent, event}, state) do
    procpid = 
    case Map.get(state.processmap, {event.env.endpoint."SensorId", event.header.process_pid, event.header.process_create_time}) do
      pid when is_pid(pid) -> pid
      nil                  -> {:ok, pid} = CbEvSyslog.Process.Worker.start_link({event.env.endpoint."SensorId", event.header.process_pid, event.header.process_create_time})
                              pid
    end
    GenServer.cast(procpid, {:ev, event})
    newpidlist = Map.put(state.processmap, {event.env.endpoint."SensorId", event.header.process_pid, event.header.process_create_time}, procpid)
    newstate = Map.put(state, :processmap, newpidlist)
    {:noreply, newstate}
  end

  def handle_info({:sensor_refresh, sensorid}, state) do
    case sensor_lookup(sensorid) do
      :error    -> {:noreply, state}
      newstruct ->
        {:noreply, Map.put(state, :sensor, newstruct)}
    end
  end



  def start_link(sensorid) do
    GenServer.start_link(__MODULE__, sensorid, [])
  end

  def init(sensorid) do
    mypid = self
    case (:gproc.reg_or_locate({:n, :l, {:sensor, sensorid}})) do
      {^mypid, _} -> initiate(sensorid, CbEvSyslog.DB.Sensor.read!(sensorid))
      {_,_}       -> :ignore
    end
  end

  def initiate(sensorid, nil) do
    Logger.debug("Nothing in amnesia for this host #{sensorid} - Trigger self-lookup")
    :erlang.send_after(1000, self, {:sensor_refresh, sensorid})
    {:ok, %CbEvSyslog.Sensor{sensor: %CbEvSyslog.DB.Sensor{id: sensorid}}}
  end

  def initiate(sensorid, newstruct) do
    {:ok, %CbEvSyslog.Sensor{sensor: newstruct}}
  end


  def sensor_lookup(sensorid) do
    %{"#cbclientapitoken" => token, "#cbclientapiurl" => url} = CbEvSyslog.Creds.webcreds
    {:ok, statuscode, _headers, reference} =
    :hackney.get("#{url}/v1/sensor/#{sensorid}", [{"X-Auth-Token", token}], '', [ssl_options: [insecure: true], async: false])
    case statuscode do
      200 -> {:ok, body} = :hackney.body(reference)
             body
             |> :jsx.decode
             |> into_sensor_struct
             |> CbEvSyslog.DB.Sensor.write!
      _   -> :erlang.send_after(1000, self, {:sensor_refresh, sensorid})
             :error
    end
  end

  def into_sensor_struct(data) do
    tostruct = Enum.map(data, fn({x,y}) -> {String.to_atom(x), y} end)
    struct(CbEvSyslog.DB.Sensor, tostruct)
  end
end

