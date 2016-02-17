defmodule CbEvSyslog do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(CbEvSyslog.Egress.Syslog, []),
      supervisor(CbEvSyslog.Sensor.Supervisor, []),
      supervisor(CbEvSyslog.Process.Supervisor, []),

      ## CarbonBlack Ingress Streams
      worker(CbEvSyslog.Ingress.Procstart, []),
      worker(CbEvSyslog.Ingress.Procend, []),
      worker(CbEvSyslog.Ingress.Filemod, []),
      worker(CbEvSyslog.Ingress.Netconn, []),

      ## Resolved / Enriched Ingress Streams
      worker(CbEvSyslog.Rules.Resolved.Procstart, []),
      worker(CbEvSyslog.Rules.Resolved.Netconn, []),
      worker(CbEvSyslog.Rules.Resolved.Filemod, []),

      ## Server / WKS split
      worker(CbEvSyslog.Rules.Resolved.Srv.Procstart, []),
      worker(CbEvSyslog.Rules.Resolved.Wks.Procstart, []),
      worker(CbEvSyslog.Rules.Resolved.Unk.Procstart, []),

      worker(CbEvSyslog.Rules.Resolved.Srv.Netconn, []),
      worker(CbEvSyslog.Rules.Resolved.Wks.Netconn, []),
      worker(CbEvSyslog.Rules.Resolved.Unk.Netconn, []),




      ## Leaving these running to add additional load
      worker(CbEvSyslog.Ingress.Childproc, []),
      worker(CbEvSyslog.Ingress.Moduleload, []),
      worker(CbEvSyslog.Ingress.Module, []),
      worker(CbEvSyslog.Ingress.Regmod, []),
      worker(CbEvSyslog.Ingress.Unknown, []),


      worker(CbEvSyslog.StatsGen, [])
    ]

    opts = [strategy: :one_for_one, name: CbEvSyslog.Supervisor]
    returnme = Supervisor.start_link(children, opts)

    Supervisor.start_child(Cbserverapi2.Connection.Supervisor, ["ingress.event.procstart", &CbEvSyslog.Dispatch.evcallback/1, &CbEvSyslog.Creds.creds/0])
    Supervisor.start_child(Cbserverapi2.Connection.Supervisor, ["ingress.event.procend", &CbEvSyslog.Dispatch.evcallback/1, &CbEvSyslog.Creds.creds/0])
    Supervisor.start_child(Cbserverapi2.Connection.Supervisor, ["ingress.event.childproc", &CbEvSyslog.Dispatch.evcallback/1, &CbEvSyslog.Creds.creds/0])
    Supervisor.start_child(Cbserverapi2.Connection.Supervisor, ["ingress.event.moduleload", &CbEvSyslog.Dispatch.evcallback/1, &CbEvSyslog.Creds.creds/0])
    Supervisor.start_child(Cbserverapi2.Connection.Supervisor, ["ingress.event.module", &CbEvSyslog.Dispatch.evcallback/1, &CbEvSyslog.Creds.creds/0])
   Supervisor.start_child(Cbserverapi2.Connection.Supervisor, ["ingress.event.filemod", &CbEvSyslog.Dispatch.evcallback/1, &CbEvSyslog.Creds.creds/0])
    Supervisor.start_child(Cbserverapi2.Connection.Supervisor, ["ingress.event.regmod", &CbEvSyslog.Dispatch.evcallback/1, &CbEvSyslog.Creds.creds/0])
    Supervisor.start_child(Cbserverapi2.Connection.Supervisor, ["ingress.event.netconn", &CbEvSyslog.Dispatch.evcallback/1, &CbEvSyslog.Creds.creds/0])

    :ets.new(:proccache, [:set, :named_table, :public])
    rulestart
    returnme
  end

  def rulestart do
    GenEvent.add_handler(CbEvSyslog.Ingress.Procstart, CbEvSyslog.Rules.Procstart, []) |> IO.inspect
    GenEvent.add_handler(CbEvSyslog.Ingress.Netconn, CbEvSyslog.Rules.Netconn, []) |> IO.inspect
    GenEvent.add_handler(CbEvSyslog.Ingress.Filemod, CbEvSyslog.Rules.Filemod, []) |> IO.inspect
    GenEvent.add_handler(CbEvSyslog.Ingress.Procend, CbEvSyslog.Rules.Procend, []) |> IO.inspect
  end

  def stats do
    IO.puts("\nCbEvSyslog.Ingress.Procstart:")
    :sys.get_state(CbEvSyslog.Ingress.Procstart) |> IO.inspect
    :sys.get_state(CbEvSyslog.Rules.Resolved.Procstart) |> IO.inspect
    :sys.get_state(CbEvSyslog.Rules.Resolved.Srv.Procstart) |> IO.inspect
    :sys.get_state(CbEvSyslog.Rules.Resolved.Wks.Procstart) |> IO.inspect
    :sys.get_state(CbEvSyslog.Rules.Resolved.Unk.Procstart) |> IO.inspect
#    :sys.get_state(CbEvSyslog.Ingress.Procend) |> IO.inspect
#    :sys.get_state(CbEvSyslog.Ingress.Childproc) |> IO.inspect
#    :sys.get_state(CbEvSyslog.Ingress.Moduleload) |> IO.inspect
#    :sys.get_state(CbEvSyslog.Ingress.Module) |> IO.inspect
    IO.puts("\nCbEvSyslog.Ingress.Filemod:")
    :sys.get_state(CbEvSyslog.Ingress.Filemod) |> IO.inspect
    :sys.get_state(CbEvSyslog.Rules.Resolved.Filemod) |> IO.inspect
#    :sys.get_state(CbEvSyslog.Ingress.Regmod) |> IO.inspect
    IO.puts("\nCbEvSyslog.Ingress.Netconn:")
    :sys.get_state(CbEvSyslog.Ingress.Netconn) |> IO.inspect
    :sys.get_state(CbEvSyslog.Rules.Resolved.Netconn) |> IO.inspect
    :sys.get_state(CbEvSyslog.Rules.Resolved.Srv.Netconn) |> IO.inspect
    :sys.get_state(CbEvSyslog.Rules.Resolved.Wks.Netconn) |> IO.inspect
    :sys.get_state(CbEvSyslog.Rules.Resolved.Unk.Netconn) |> IO.inspect
#    :sys.get_state(CbEvSyslog.Ingress.Unknown) |> IO.inspect
    IO.puts("\nCbEvSyslog.Egress.Syslog:")
    :sys.get_state(CbEvSyslog.Egress.Syslog) |> IO.inspect
    :ok
  end


end
