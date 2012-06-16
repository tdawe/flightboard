$(document).ready(function() {
    load_boards();
});

function load_boards()
{
    $.getJSON("/airports/"+icao+"/arrivals.json", function(data) { load_arrivals(data) });
    $.getJSON("/airports/"+icao+"/departures.json", function(data) { load_departures(data) });
    setTimeout("load_boards()", 60000);
}

function load_arrivals(data)
{
    $("#arrivals > tbody > tr").remove();

    $.each(data, function(index, arrival) {

        row_class = ""
        if(arrival.arrival_status == "Early")
            row_class = "early"
        else if(arrival.arrival_status == "Late")
            row_class = "late"
        else if(arrival.arrival_status == "On Time")
            row_class = "on_time"

        arrival.scheduled_departure_time = arrival.scheduled_departure_time == null ? "" : arrival.scheduled_departure_time
        arrival.scheduled_arrival_time = arrival.scheduled_arrival_time == null ? "" : arrival.scheduled_arrival_time
        arrival.estimated_arrival_time = arrival.estimated_arrival_time == null ? "" : arrival.estimated_arrival_time

        $('#arrivals > tbody:last').append('<tr class=\"'+row_class+'\">' +
            '<td>'+arrival.callsign+'</td>' +
            '<td>'+arrival.planned_aircraft+'</td>' +
            '<td>'+arrival.planned_depairport+'</td>' +
            '<td>'+arrival.scheduled_departure_time+'</td>' +
            '<td>'+arrival.scheduled_arrival_time+'</td>' +
            '<td>'+arrival.estimated_arrival_time+'</td>' +
            '<td>'+arrival.arrival_status+'</td>' +
            '<td>'+arrival.flight_status+'</td>');
    });
}

function load_departures(data)
{
    $("#departures > tbody > tr").remove();

    $.each(data, function(index, departure) {

        row_class = ""
        if(departure.arrival_status == "Early")
            row_class = "early"
        else if(departure.arrival_status == "Late")
            row_class = "late"
        else if(departure.arrival_status == "On Time")
            row_class = "on_time"

        departure.scheduled_departure_time = departure.scheduled_departure_time == null ? "" : departure.scheduled_departure_time
        departure.scheduled_arrival_time = departure.scheduled_arrival_time == null ? "" : departure.scheduled_arrival_time
        departure.estimated_arrival_time = departure.estimated_arrival_time == null ? "" : departure.estimated_arrival_time

        $('#departures > tbody:last').append('<tr class=\"'+row_class+'\">' +
            '<td>'+departure.callsign+'</td>' +
            '<td>'+departure.planned_aircraft+'</td>' +
            '<td>'+departure.planned_destairport+'</td>' +
            '<td>'+departure.scheduled_departure_time+'</td>' +
            '<td>'+departure.scheduled_arrival_time+'</td>' +
            '<td>'+departure.estimated_arrival_time+'</td>' +
            '<td>'+departure.arrival_status+'</td>' +
            '<td>'+departure.flight_status+'</td>');
    });
}

