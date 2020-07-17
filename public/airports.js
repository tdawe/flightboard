$(document).ready(function() {
    load_boards();
    timer();
    updateTime();
});

function timer() {
    var timeleft = 150;
    var downloadTimer = setInterval(function(){     
      updateTime();
      if(timeleft <= 0){
        clearInterval(downloadTimer);
        document.getElementById("countdown").innerHTML = "Refreshing...";
      } else {
        document.getElementById("countdown").innerHTML = "Refreshing in " + timeleft + " seconds";
      }
      timeleft -= 1;
    }, 1000);
}

function updateTime() {
  var today = new Date();
  var y = today.getUTCFullYear();
  var month = today.getUTCMonth() + 1;
  var day = today.getUTCDate();
  var h = today.getUTCHours();
  var m = today.getUTCMinutes();
  var s = today.getUTCSeconds();
  month = checkTime(month);
  m = checkTime(m);
  s = checkTime(s);
  document.getElementById('currenttime').innerHTML =
  y + "-" + month + "-" + day + " " + h + ":" + m + ":" + s + " UTC";
}
function checkTime(i) {
  if (i < 10) {i = "0" + i};  // add zero in front of numbers < 10
  return i;
}

function load_boards()
{
    $.getJSON("/airports/"+icao+"/arrivals.json", function(data) { load_arrivals(data) });
    $.getJSON("/airports/"+icao+"/departures.json", function(data) { load_departures(data) });
    setTimeout("load_boards(); timer();", 150000);
}

function load_arrivals(data)
{
    $("#arrivals-on-the-way > tbody > tr").remove();
    $("#arrivals-arrived > tbody > tr").remove();
    $("#arrivals-at-departure-airport > tbody > tr").remove();

    $.each(data, function(index, arrival) {
        table = "arrivals-on-the-way"
        if(arrival.flight_status == "On the way" || arrival.flight_status == "Departing")
            table = "arrivals-on-the-way"
        else if(arrival.flight_status == "At Gate" || arrival.flight_status == "Taxiing to Gate")
            table = "arrivals-arrived"
        else if(arrival.flight_status == "Boarding")
            table = "arrivals-at-departure-airport"
        
        row_class = ""

        arrival.scheduled_departure_time = arrival.scheduled_departure_time == null ? "" : arrival.scheduled_departure_time
        arrival.scheduled_arrival_time = arrival.scheduled_arrival_time == null ? "" : arrival.scheduled_arrival_time
        arrival.estimated_arrival_time = arrival.estimated_arrival_time == null ? "" : arrival.estimated_arrival_time

        $('#' + table + ' > tbody:last').append('<tr class=\"'+row_class+'\">' +
            '<td>'+arrival.callsign+'</td>' +
            '<td>'+arrival.planned_aircraft+'</td>' +
            '<td>'+arrival.planned_depairport+'</td>' +
            '<td>'+arrival.scheduled_departure_time+'</td>' +
            '<td>'+arrival.scheduled_arrival_time+'</td>' +
            '<td>'+arrival.estimated_arrival_time+'</td>' +
            '<td>'+arrival.arrival_status+'</td>' +
            '<td>'+arrival.flight_status+'</td>' +
	    '<td>'+arrival.plain_text_status+'</td>');
    });
}

function load_departures(data)
{
    $("#departures-on-the-way > tbody > tr").remove();
    $("#departures-arrived-at-arrival-airport > tbody > tr").remove();
    $("#departures-boarding > tbody > tr").remove();

    $.each(data, function(index, departure) {
        table = "departures-on-the-way"
        if(departure.flight_status == "On the way" || departure.flight_status == "Departing")
            table = "departures-on-the-way"
        else if(departure.flight_status == "At the gate" || departure.flight_status == "Taxxing to the gate")
            table = "departures-arrived-at-arrival-airport"
        else if(departure.flight_status == "Boarding")
            table = "departures-boarding"
        
        row_class = ""

        departure.scheduled_departure_time = departure.scheduled_departure_time == null ? "" : departure.scheduled_departure_time
        departure.scheduled_arrival_time = departure.scheduled_arrival_time == null ? "" : departure.scheduled_arrival_time
        departure.estimated_arrival_time = departure.estimated_arrival_time == null ? "" : departure.estimated_arrival_time

        $('#' + table + ' > tbody:last').append('<tr class=\"'+row_class+'\">' +
            '<td>'+departure.callsign+'</td>' +
            '<td>'+departure.planned_aircraft+'</td>' +
            '<td>'+departure.planned_destairport+'</td>' +
            '<td>'+departure.scheduled_departure_time+'</td>' +
            '<td>'+departure.scheduled_arrival_time+'</td>' +
            '<td>'+departure.estimated_arrival_time+'</td>' +
            '<td>'+departure.arrival_status+'</td>' +
            '<td>'+departure.flight_status+'</td>' +
	    '<td>'+departure.plain_text_status+'</td>');
    });
}

