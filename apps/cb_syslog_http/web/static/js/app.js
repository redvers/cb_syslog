// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket"
import channel from "./socket"

var procstart = new SmoothieChart({millisPerPixel:100,grid:{millisPerLine:7000},timestampFormatter:SmoothieChart.timeFormatter,horizontalLines:[{color:'#ffffff',lineWidth:1,value:0},{color:'#880000',lineWidth:2,value:3333},{color:'#880000',lineWidth:2,value:-3333}]}),
    procstartcanvas = document.getElementById('procstart'),
    procstartseries = new TimeSeries();


var procend = new SmoothieChart({millisPerPixel:100,grid:{millisPerLine:7000},timestampFormatter:SmoothieChart.timeFormatter,horizontalLines:[{color:'#ffffff',lineWidth:1,value:0},{color:'#880000',lineWidth:2,value:3333},{color:'#880000',lineWidth:2,value:-3333}]}),
    procendcanvas = document.getElementById('procend'),
    procendseries = new TimeSeries();

var childproc = new SmoothieChart({millisPerPixel:100,grid:{millisPerLine:7000},timestampFormatter:SmoothieChart.timeFormatter,horizontalLines:[{color:'#ffffff',lineWidth:1,value:0},{color:'#880000',lineWidth:2,value:3333},{color:'#880000',lineWidth:2,value:-3333}]}),
    childproccanvas = document.getElementById('childproc'),
    childprocseries = new TimeSeries();

var moduleload = new SmoothieChart({millisPerPixel:100,grid:{millisPerLine:7000},timestampFormatter:SmoothieChart.timeFormatter,horizontalLines:[{color:'#ffffff',lineWidth:1,value:0},{color:'#880000',lineWidth:2,value:3333},{color:'#880000',lineWidth:2,value:-3333}]}),
    moduleloadcanvas = document.getElementById('moduleload'),
    moduleloadseries = new TimeSeries();

var module = new SmoothieChart({millisPerPixel:100,grid:{millisPerLine:7000},timestampFormatter:SmoothieChart.timeFormatter,horizontalLines:[{color:'#ffffff',lineWidth:1,value:0},{color:'#880000',lineWidth:2,value:3333},{color:'#880000',lineWidth:2,value:-3333}]}),
    modulecanvas = document.getElementById('module'),
    moduleseries = new TimeSeries();

var filemod = new SmoothieChart({millisPerPixel:100,grid:{millisPerLine:7000},timestampFormatter:SmoothieChart.timeFormatter,horizontalLines:[{color:'#ffffff',lineWidth:1,value:0},{color:'#880000',lineWidth:2,value:3333},{color:'#880000',lineWidth:2,value:-3333}]}),
    filemodcanvas = document.getElementById('filemod'),
    filemodseries = new TimeSeries();

var regmod = new SmoothieChart({millisPerPixel:100,grid:{millisPerLine:7000},timestampFormatter:SmoothieChart.timeFormatter,horizontalLines:[{color:'#ffffff',lineWidth:1,value:0},{color:'#880000',lineWidth:2,value:3333},{color:'#880000',lineWidth:2,value:-3333}]}),
    regmodcanvas = document.getElementById('regmod'),
    regmodseries = new TimeSeries();

var netconn = new SmoothieChart({millisPerPixel:100,grid:{millisPerLine:7000},timestampFormatter:SmoothieChart.timeFormatter,horizontalLines:[{color:'#ffffff',lineWidth:1,value:0},{color:'#880000',lineWidth:2,value:3333},{color:'#880000',lineWidth:2,value:-3333}]}),
    netconncanvas = document.getElementById('netconn'),
    netconnseries = new TimeSeries();

var unknown = new SmoothieChart({millisPerPixel:100,grid:{millisPerLine:7000},timestampFormatter:SmoothieChart.timeFormatter,horizontalLines:[{color:'#ffffff',lineWidth:1,value:0},{color:'#880000',lineWidth:2,value:3333},{color:'#880000',lineWidth:2,value:-3333}]}),
    unknowncanvas = document.getElementById('unknown'),
    unknownseries = new TimeSeries();

var syslog = new SmoothieChart({millisPerPixel:100,grid:{millisPerLine:7000},timestampFormatter:SmoothieChart.timeFormatter,horizontalLines:[{color:'#ffffff',lineWidth:1,value:0},{color:'#880000',lineWidth:2,value:3333},{color:'#880000',lineWidth:2,value:-3333}]}),
    syslogcanvas = document.getElementById('syslog'),
    syslogseries = new TimeSeries();


procstart.addTimeSeries(procstartseries, {lineWidth:2,strokeStyle:'#00ff00'});
procend.addTimeSeries(procendseries, {lineWidth:2,strokeStyle:'#00ff00'});
childproc.addTimeSeries(childprocseries, {lineWidth:2,strokeStyle:'#00ff00'});
moduleload.addTimeSeries(moduleloadseries, {lineWidth:2,strokeStyle:'#00ff00'});
module.addTimeSeries(moduleseries, {lineWidth:2,strokeStyle:'#00ff00'});
filemod.addTimeSeries(filemodseries, {lineWidth:2,strokeStyle:'#00ff00'});
regmod.addTimeSeries(regmodseries, {lineWidth:2,strokeStyle:'#00ff00'});
netconn.addTimeSeries(netconnseries, {lineWidth:2,strokeStyle:'#00ff00'});
unknown.addTimeSeries(unknownseries, {lineWidth:2,strokeStyle:'#00ff00'});
syslog.addTimeSeries(syslogseries, {lineWidth:2,strokeStyle:'#00ff00'});



procstart.streamTo(procstartcanvas, 500);
procend.streamTo(procendcanvas, 500);
childproc.streamTo(childproccanvas, 500);
moduleload.streamTo(moduleloadcanvas, 500);
module.streamTo(modulecanvas, 500);
filemod.streamTo(filemodcanvas, 500);
regmod.streamTo(regmodcanvas, 500);
netconn.streamTo(netconncanvas, 500);
unknown.streamTo(unknowncanvas, 500);
syslog.streamTo(syslogcanvas, 500);

channel.on("new_msg", payload => {
  console.log(payload);
  procstartseries.append(new Date().getTime(), payload.Procstart);
  procendseries.append(new Date().getTime(), payload.Procend);
  childprocseries.append(new Date().getTime(), payload.Childproc);
  moduleloadseries.append(new Date().getTime(), payload.Moduleload);
  moduleseries.append(new Date().getTime(), payload.Module);
  filemodseries.append(new Date().getTime(), payload.Filemod);
  regmodseries.append(new Date().getTime(), payload.Regmod);
  netconnseries.append(new Date().getTime(), payload.Netconn);
  unknownseries.append(new Date().getTime(), payload.Unknown);
  syslogseries.append(new Date().getTime(), payload.Syslog);
   });











