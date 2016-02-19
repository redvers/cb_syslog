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
    domainlines = File.read!("/etc/cb/cb.conf")
    |> String.split("\n")
    |> Enum.filter(&(Regex.match?(~r/^#ldapaddomain/i, &1)))
    |> Enum.reduce(Map.new, fn(x, acc) -> Map.merge(acc, parse_ldap_line(x)) end)
  end

  def parse_ldap_line(x) do
    [_,user,pass,domain,base,server] = String.split(x, ":")
    Map.new
    |> Map.put(domain, %{user: user, pass: pass, base: base, server: server})
  end





end
