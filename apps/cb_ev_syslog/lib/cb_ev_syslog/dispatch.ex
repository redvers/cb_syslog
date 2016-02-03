defmodule CbEvSyslog.Dispatch do
  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.procstart"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Procstart, :sensor_events.decode_msg(payload, :CbEventMsg))
  end

  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.procend"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Procend, :sensor_events.decode_msg(payload, :CbEventMsg))
  end

  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.childproc"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Childproc, :sensor_events.decode_msg(payload, :CbEventMsg))
  end

  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.moduleload"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Moduleload, :sensor_events.decode_msg(payload, :CbEventMsg))
  end

  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.module"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Module, :sensor_events.decode_msg(payload, :CbEventMsg))
  end

  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.filemod"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Filemod, :sensor_events.decode_msg(payload, :CbEventMsg))
  end

  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.regmod"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Regmod, :sensor_events.decode_msg(payload, :CbEventMsg))
  end

  def evcallback({
    {:"basic.deliver", tag, serial, _, "api.events", "ingress.event.netconn"},
    {:amqp_msg, {:P_basic, "application/protobuf",_,_,_,_,_,_,_,_,_,_,_,_,_}, payload}}) do
    GenEvent.notify(CbEvSyslog.Ingress.Netconn, :sensor_events.decode_msg(payload, :CbEventMsg))
  end
  def evcallback(unknownmessage) do
    GenEvent.notify(CbEvSyslog.Ingress.Unknown, unknownmessage)
  end

end
