defmodule CbEvSyslog.Rules.Helper do
  def enrich_header(event) do
    event
    |> put_in([:header, :process_md5], process_md5(event.header.process_md5))
    |> put_in([:header, :process_guid], guid(event))
    |> put_in([:header, :timestamp], timestamp(event))
  end

  def enrich_filemod(event) do
    event
    |> put_in([:filemod, :md5hash], process_md5(event.filemod.md5hash))
  end

  def enrich_process(event) do
    event
    |> put_in([:process, :md5hash], process_md5(event.process.md5hash))
    |> put_in([:process, :parent_md5], process_md5(event.process.parent_md5))
    |> put_in([:process, :parent_guid], guid(%{header: %{process_create_time: event.process.parent_create_time, process_pid: event.process.parent_pid}, env: %{endpoint: %{"SensorId": event.env.endpoint."SensorId"}}}))
  end

  def enrich_netconn(event) do
    event
    |> put_in([:network, :ipv4Address],      format_ipaddr(event.network.ipv4Address))
    |> put_in([:network, :localIpAddress],   format_ipaddr(event.network.localIpAddress))
    |> put_in([:network, :remoteIpAddress],  format_ipaddr(event.network.remoteIpAddress))
    |> put_in([:network, :proxyIpv4Address], format_ipaddr(event.network.proxyIpv4Address))
    |> put_in([:network, :port],             format_port(event.network.port))
    |> put_in([:network, :localPort],        format_port(event.network.localPort))
    |> put_in([:network, :remotePort],       format_port(event.network.remotePort))
    |> put_in([:network, :proxyPort],        format_port(event.network.proxyPort))
    |> put_in([:network, :fqdnsplit],        split_fqdn(event.network.utf8_netpath))
  end

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

  def to_syslog(string) do
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

