defmodule CbSyslog.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  defp deps do
    [{:exrm, git: "https://github.com/bitwalker/exrm"}]
  end
end
