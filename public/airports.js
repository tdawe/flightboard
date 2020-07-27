var updateTimeout;
var downloadTimer;
//var markers = [];
var flightMarkers = [];
var flightArrivals = [];
var flightDepartures = []
var map;
var airportLocation;
var caller = [];
var mapMarkers = { markers: [] }

$(document).ready(function() {
    //flightMarkers = new Array();
    loadMap();
    load_boards();
});

function loadMap() {
    map = L.map('map', {
    center: [51.505, -0.09],
    zoom: 11
    });
    	L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
		maxZoom: 18,
		attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, ' +
			'<a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
			'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
		id: 'mapbox/streets-v11',
		tileSize: 512,
		zoomOffset: -1
	}).addTo(map);
   //markers = new L.FeatureGroup();
   //markers.addTo(map);
    setTimeout("centerMap();", 1000);

}

function centerMap() {
    map.panTo(airportLocation);
}

function updateMarkers() {    
    $.each(mapMarkers.markers, function(index, marker) {
        map.removeLayer(marker);
    });
    
    mapMarkers.markers = [];
    
    $.each(flightArrivals, function(index, flight) {
        var plane = L.icon({ iconUrl: "/airplane.png", iconSize: [25, 25], iconAnchor: [12, 12] })
        var title = flight.callsign + "\n" + flight.planned_depairport + " - " + flight.planned_destairport + "\n" + flight.altitude + "ft / " + flight.groundspeed + "kts"
        var marker = L.marker([flight.latitude, flight.longitude], {title: title, icon: plane, rotationAngle: flight.heading })
        marker.addTo(map)
        mapMarkers.markers.push(marker);
        
        var polyline = L.polyline(flight.locations, {color: 'red'}).addTo(map);
        mapMarkers.markers.push(polyline);

    });
           
    $.each(flightDepartures, function(index, flight) {
        var plane = L.icon({ iconUrl: "/airplane.png", iconSize: [25, 25], iconAnchor: [12, 12] })
        var title = flight.callsign + "\n" + flight.planned_depairport + " - " + flight.planned_destairport + "\n" + flight.altitude + "ft / " + flight.groundspeed + " kts"
        var marker = L.marker([flight.latitude, flight.longitude], {title: title, icon: plane, rotationAngle: flight.heading })
        marker.addTo(map)
        mapMarkers.markers.push(marker);
        
        var polyline = L.polyline(flight.locations, {color: 'blue'}).addTo(map);
        mapMarkers.markers.push(polyline);
    });
    console.log("after updateMarkers length = " + mapMarkers.markers.length);
}

function timer() {
    var timeleft = 150;
    clearInterval(downloadTimer);
    downloadTimer = setInterval(function(){     
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
    clearTimeout(updateTimeout);
    timer();
    $.getJSON("/airports/"+icao+"/arrivals.json", function(data) { 
        load_arrivals(data);
        $.getJSON("/airports/"+icao+"/departures.json", function(data) { 
            load_departures(data);
            updateMarkers();

        });
    });
    updateTimeout = setTimeout("load_boards();", 150000);
}

function load_arrivals(data)
{
    $("#arrivals-on-the-way > tbody > tr").remove();
    $("#arrivals-arrived > tbody > tr").remove();
    $("#arrivals-at-departure-airport > tbody > tr").remove();
    
    $("#div-arrivals-on-the-way").hide();
    $("#div-arrivals-arrived").hide();
    $("#div-arrivals-at-departure-airport").hide();
    
    flightArrivals = []
    
    $.each(data, function(index, arrival) {
        airportLocation = L.latLng(arrival.planned_destairport_lat, arrival.planned_destairport_lon)
        table = "arrivals-on-the-way"
        if(arrival.flight_status == "On the way" || arrival.flight_status == "Departing")
            table = "arrivals-on-the-way"
        else if(arrival.flight_status == "At Gate" || arrival.flight_status == "Taxiing to Gate")
            table = "arrivals-arrived"
        else if(arrival.flight_status == "Boarding")
            table = "arrivals-at-departure-airport"
        
        row_class = ""
        
        flightArrivals.push(arrival)

        arrival.scheduled_departure_time = arrival.scheduled_departure_time == null ? "" : arrival.scheduled_departure_time
        arrival.scheduled_arrival_time = arrival.scheduled_arrival_time == null ? "" : arrival.scheduled_arrival_time
        arrival.estimated_arrival_time = arrival.estimated_arrival_time == null ? "" : arrival.estimated_arrival_time

        $("#div-" + table).show();

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
    $("#departures-departed > tbody > tr").remove();
    $("#departures-at-arrival-airport > tbody > tr").remove();
    $("#departures-boarding > tbody > tr").remove();

    $("#div-departures-departed").hide();
    $("#div-departures-at-arrival-airport").hide();
    $("#div-departures-boarding").hide();
  
    flightDepartures = []
    
    $.each(data, function(index, departure) {
        airportLocation = L.latLng(departure.planned_depairport_lat, departure.planned_depairport_lon)

        table = "departures-departed"
        if(departure.flight_status == "On the way" || departure.flight_status == "Departing")
            table = "departures-departed"
        else if(departure.flight_status == "At Gate" || departure.flight_status == "Taxiing to Gate")
            table = "departures-at-arrival-airport"
        else if(departure.flight_status == "Boarding")
            table = "departures-boarding"
        
        row_class = ""

        flightDepartures.push(departure)

        departure.scheduled_departure_time = departure.scheduled_departure_time == null ? "" : departure.scheduled_departure_time
        departure.scheduled_arrival_time = departure.scheduled_arrival_time == null ? "" : departure.scheduled_arrival_time
        departure.estimated_arrival_time = departure.estimated_arrival_time == null ? "" : departure.estimated_arrival_time

        $("#div-" + table).show();

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

