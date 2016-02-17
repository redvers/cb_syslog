defmodule CbEvSyslog.Creds do
  def creds do
    mqdata = File.read!("/etc/cb/cb.conf")
    |> String.split("\n")
    |> Enum.filter(&(Regex.match?(~r/^RabbitMQ/i, &1)))
    |> Enum.reduce(%{}, fn(x, acc) -> [field, value] = String.split(x, "=") ; Map.put(acc, String.downcase(field), value) end)

    %{hostname: "127.0.0.1",
      password: Map.get(mqdata, "rabbitmqpassword"),
      port:     Map.get(mqdata, "rabbitmqport"),
      username: Map.get(mqdata, "rabbitmquser")}
  end

  def webcreds do
    webcreddata = File.read!("/etc/cb/cb.conf")
    |> String.split("\n")
    |> Enum.filter(&(Regex.match?(~r/^#cbclientapi/i, &1)))
    |> Enum.reduce(%{}, fn(x, acc) -> [field, value] = String.split(x, "=") ; Map.put(acc, String.downcase(field), value) end)
  end

  def ldapcreds do
    ldapcreddata = File.read!("/etc/cb/cb.conf")
    |> String.split("\n")
    |> Enum.filter(&(Regex.match?(~r/^#ldapad/i, &1)))
#    |> Enum.map(%{"#ldapaddomain" => %{}, "#ldapaduser" => "", "#ldapadpass" => ""}, fn(x,acc) ->
    |> Enum.map(&parse_ldap_line/1)
  end

  def parse_ldap_line(x) do
    [key, val] = String.split(x, ":")
    case key do
      "#ldapaddomain" ->
        [domain, dn] = String.split(val, ";")
        {domain, dn}
      other ->
        {key, val}
    end
  end





end
