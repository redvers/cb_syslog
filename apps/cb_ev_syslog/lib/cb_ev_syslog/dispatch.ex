defmodule CbEvSyslog.Dispatch do
  defstruct event: nil, type: nil, drop: false, sendto: []
  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.procstart"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Procstart, %CbEvSyslog.Dispatch{event: :sensor_events.decode_msg(payload, :CbEventMsg), type: :procstart})
  end

  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.procend"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Procend,  %CbEvSyslog.Dispatch{event: :sensor_events.decode_msg(payload, :CbEventMsg), type: :procend})
  end

  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.childproc"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Childproc,  %CbEvSyslog.Dispatch{event: :sensor_events.decode_msg(payload, :CbEventMsg), type: :childproc})
  end

  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.moduleload"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Moduleload,  %CbEvSyslog.Dispatch{event: :sensor_events.decode_msg(payload, :CbEventMsg), type: :moduleload})
  end

  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.module"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Module,  %CbEvSyslog.Dispatch{event: :sensor_events.decode_msg(payload, :CbEventMsg), type: :module})
  end

  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.filemod"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Filemod,  %CbEvSyslog.Dispatch{event: :sensor_events.decode_msg(payload, :CbEventMsg), type: :filemod})
  end

  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.regmod"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Regmod,  %CbEvSyslog.Dispatch{event: :sensor_events.decode_msg(payload, :CbEventMsg), type: :regmod})
  end

  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.netconn"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Netconn,  %CbEvSyslog.Dispatch{event: :sensor_events.decode_msg(payload, :CbEventMsg), type: :netconn})
  end
  def evcallback(unknownmessage) do
    GenEvent.notify(CbEvSyslog.Ingress.Unknown, unknownmessage)
  end

end
