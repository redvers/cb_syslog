defmodule CbEvSyslog.Mixfile do
  use Mix.Project

  def project do
    [app: :cb_ev_syslog,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :cbserverapi2, :syslog, :runtime_tools, :jsx, :sasl],
    mod: {CbEvSyslog, []}]
  end

  defp deps do
    [
      {:cbserverapi2, git: "https://github.com/redvers/cbserverapi2.git"},
      {:syslog, "~> 1.0.2"},
      {:jsx, "~> 2.8.0"}
    ]
  end
end
