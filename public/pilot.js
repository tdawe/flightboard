var updateTimeout;
var downloadTimer;
//var markers = [];
var pilotStatus;
var map;
var airportLocation;
var mapMarkers = { markers: [] }

$(document).ready(function() {
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

    var plane = L.icon({ iconUrl: "/airplane.png", iconSize: [25, 25], iconAnchor: [12, 12] })
    var title = pilotStatus.callsign + "\n" + pilotStatus.planned_depairport + " - " + pilotStatus.planned_destairport + "\n" + pilotStatus.altitude + "ft / " + pilotStatus.groundspeed + "kts"
    var marker = L.marker([pilotStatus.latitude, pilotStatus.longitude], {title: title, icon: plane, rotationAngle: pilotStatus.heading })
    marker.addTo(map)
    mapMarkers.markers.push(marker);
        
    var polyline = L.polyline(pilotStatus.locations, {color: 'red'}).addTo(map);
    mapMarkers.markers.push(polyline);
    
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
    $.getJSON("/pilots/"+callsign+"/status.json", function(data) { 
        load_pilot(data);
        updateMarkers();
    });
    updateTimeout = setTimeout("load_boards();", 150000);
}

function load_pilot(pilot)
{
    $("#pilot-status > tbody > tr").remove();
        
    flightArrivals = []
    
     airportLocation = L.latLng(pilot.latitude, pilot.longitude)
        
     pilotStatus = pilot
    
     pilot.scheduled_departure_time = pilot.scheduled_departure_time == null ? "" : pilot.scheduled_departure_time
     pilot.scheduled_arrival_time = pilot.scheduled_arrival_time == null ? "" : pilot.scheduled_arrival_time
     pilot.estimated_arrival_time = pilot.estimated_arrival_time == null ? "" : pilot.estimated_arrival_time


        $('#pilot-status > tbody:last').append('<tr>' +
            '<td>'+pilot.callsign+'</td>' +
            '<td>'+pilot.planned_aircraft+'</td>' +
            '<td><a href="/airports/'+pilot.planned_depairport+'">'+pilot.planned_depairport+'</a></td>' +
            '<td><a href="/airports/'+pilot.planned_destairport+'">'+pilot.planned_destairport+'</a></td>' +
            '<td>'+pilot.scheduled_departure_time+'</td>' +
            '<td>'+pilot.scheduled_arrival_time+'</td>' +
            '<td>'+pilot.estimated_arrival_time+'</td>' +
            '<td>'+pilot.arrival_status+'</td>' +
            '<td>'+pilot.flight_status+'</td>' +
	    '<td>'+pilot.plain_text_status+'</td>');
}

