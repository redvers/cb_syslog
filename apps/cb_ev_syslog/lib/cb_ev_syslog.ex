defmodule CbEvSyslog do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(CbEvSyslog.Egress.Syslog, []),

      worker(CbEvSyslog.Ingress.Procstart, []),
      worker(CbEvSyslog.Ingress.Procend, []),
      worker(CbEvSyslog.Ingress.Childproc, []),
      worker(CbEvSyslog.Ingress.Moduleload, []),
      worker(CbEvSyslog.Ingress.Module, []),
      worker(CbEvSyslog.Ingress.Filemod, []),
      worker(CbEvSyslog.Ingress.Regmod, []),
      worker(CbEvSyslog.Ingress.Netconn, []),
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

    rulestart
    returnme
  end

  def rulestart do
    GenEvent.add_handler(CbEvSyslog.Ingress.Netconn, CbEvSyslog.Rules.Netconn, []) |> IO.inspect
    GenEvent.add_handler(CbEvSyslog.Ingress.Filemod, CbEvSyslog.Rules.Filemod, []) |> IO.inspect
    GenEvent.add_handler(CbEvSyslog.Ingress.Procstart, CbEvSyslog.Rules.Procstart, []) |> IO.inspect
  end


end
