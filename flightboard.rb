require 'sinatra'
require 'haml'
require File.dirname(__FILE__) + '/models.rb'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.db")
DataMapper::Property::String.length(255)

require './models.rb'

DataMapper.auto_upgrade!

get '/refreshdata' do
  output = ""
  data = Vatsim::Data.new
  Pilot.transaction do
    Pilot.destroy
    data.pilots.each { |pilot|
      _scheduled_departure_time = scheduled_departure_time(pilot)
      _scheduled_arrival_time = scheduled_arrival_time(pilot)
      _estimated_arrival_time = estimated_arrival_time(pilot)
      _arrival_status = arrival_status(pilot)
      _flight_status = flight_status(pilot)
      Pilot.create(:callsign => pilot.callsign, :cid => pilot.cid, :realname => pilot.realname, :clienttype => pilot.clienttype, :latitude => pilot.latitude, :longitude => pilot.longitude, :altitude => pilot.altitude, :groundspeed => pilot.groundspeed, :planned_aircraft =>           pilot.planned_aircraft, :planned_tascruise => pilot.planned_tascruise, :planned_depairport => pilot.planned_depairport, :planned_altitude => pilot.planned_altitude, :planned_destairport => pilot.planned_destairport, :server => pilot.server, :protrevision => pilot.protrevision, :rating => pilot.rating, :transponder => pilot.transponder, :planned_revision => pilot.planned_revision, :planned_flighttype => pilot.planned_flighttype, :planned_deptime => pilot.planned_deptime, :planned_actdeptime => pilot.planned_actdeptime, :planned_hrsenroute => pilot.planned_minenroute, :planned_hrsfuel => pilot.planned_minfuel, :planned_altairport => pilot.planned_altairport, :planned_remarks => pilot.planned_remarks, :planned_route => pilot.planned_route, :planned_depairport_lat => pilot.planned_depairport_lat, :planned_depairport_lon => pilot.planned_depairport_lon, :planned_destairport_lat => pilot.planned_destairport_lat, :planned_destairport_lon => pilot.planned_destairport_lon, :time_logon => pilot.time_logon, :heading => pilot.heading, :QNH_iHg => pilot.QNH_iHg, :QNH_Mb => pilot.QNH_Mb, :scheduled_departure_time => _scheduled_departure_time, :scheduled_arrival_time => _scheduled_arrival_time, :estimated_arrival_time => _estimated_arrival_time, :arrival_status => _arrival_status, :flight_status => _flight_status)
    }
  end
  "Loaded #{Pilot.all.length} pilots"
end

get '/' do
  @pilots = Pilot.all
  @airports = Array.new
  @pilots.each { |pilot|
    @airports << pilot.planned_depairport if !@airports.include?(pilot.planned_depairport)
    @airports << pilot.planned_destairport if !@airports.include?(pilot.planned_destairport)
  }
  haml :index
end

get '/pilots' do
  @pilots = Pilot.all
  haml :pilots
end

get '/pilots/:callsign' do
  @pilot = Pilot.get(params[:callsign])
  haml :pilot
end

get '/airports' do
  pilots = Pilot.all
  @airports = Array.new
  pilots.each { |pilot|
    @airports << pilot.planned_depairport if !@airports.include?(pilot.planned_depairport)
    @airports << pilot.planned_destairport if !@airports.include?(pilot.planned_destairport)
  }
  haml :airports
end

get '/airports/:icao' do
  @arrivals = Pilot.all(:planned_destairport => params[:icao], :order => [:scheduled_arrival_time.asc])
  @departures = Pilot.all(:planned_depairport => params[:icao], :order => [:scheduled_arrival_time.asc])
  haml :airport
end

##############################333

def scheduled_departure_time pilot
  now = Time.now
  departure_time = pilot.planned_deptime.eql?("0") ? nil : pilot.planned_deptime
  #handles invalid times
  departure_time = nil if pilot.planned_deptime.to_i > 2359

  if !departure_time.nil?
    hours = (pilot.planned_deptime.to_i / 100).to_i;
    minutes = pilot.planned_deptime.to_i - ((pilot.planned_deptime.to_i / 100).to_i * 100)
    departure_time = Time.gm(now.year, now.month, now.day, hours, minutes)
  end

  return departure_time
end

def scheduled_arrival_time pilot
  deptime = scheduled_departure_time pilot
  return deptime if deptime.nil?
  return deptime + (pilot.planned_hrsenroute.to_i * 60*60) + (pilot.planned_minenroute.to_i*60)
end

def estimated_arrival_time pilot
  _flight_status = flight_status(pilot)
  return nil if(!(_flight_status.eql?("On the way") or _flight_status.eql?("Arriving"))) # or !_flight_status.eql?("Arriving"))
  return nil if pilot.planned_destairport_lat.eql?("0")
  distance = haversine_distance(pilot.latitude.to_f, pilot.longitude.to_f, pilot.planned_destairport_lat.to_f, pilot.planned_destairport_lon.to_f)
  return nil if pilot.groundspeed.to_i == 0
  time_for_distance = distance / pilot.groundspeed.to_i
  return Time.now.getgm + (time_for_distance * 60 * 60)
end

def flight_status pilot
  status = "On the way"
  distance_from_depairport = haversine_distance(pilot.latitude.to_f, pilot.longitude.to_f, pilot.planned_depairport_lat.to_f, pilot.planned_depairport_lon.to_f)
  distance_from_destairport = haversine_distance(pilot.latitude.to_f, pilot.longitude.to_f, pilot.planned_destairport_lat.to_f, pilot.planned_destairport_lon.to_f)
  status = "Boarding" if distance_from_depairport < 5 and pilot.groundspeed.to_i == 0
  status = "Left Gate" if distance_from_depairport < 5 and pilot.groundspeed.to_i > 0
  status = "Departing" if distance_from_depairport < 25 and pilot.groundspeed.to_i > 0
  status = "Arriving" if distance_from_destairport < 50 and pilot.groundspeed.to_i > 0
  status = "Taxiing to Gate" if distance_from_destairport < 5 and pilot.groundspeed.to_i > 0
  status = "At Gate" if distance_from_destairport < 5 and pilot.groundspeed.to_i == 0
  status
end

def arrival_status pilot
  status = "On Time"

  distance_from_depairport = haversine_distance(pilot.latitude.to_f, pilot.longitude.to_f, pilot.planned_depairport_lat.to_f, pilot.planned_depairport_lon.to_f)

  return "N/A" if scheduled_arrival_time(pilot).nil? or estimated_arrival_time(pilot).nil?
  status = "Late" if estimated_arrival_time(pilot) > scheduled_arrival_time(pilot)
  status = "Early" if estimated_arrival_time(pilot) < scheduled_arrival_time(pilot)
  return status
end

RAD_PER_DEG = 0.017453293
Rnm = 3440.07

def haversine_distance(lat1, lng1, lat2, lng2)

        dlng = lng2 - lng1
        dlat = lat2 - lat1

        dlng_rad = dlng * RAD_PER_DEG
        dlat_rad = dlat * RAD_PER_DEG

        lat1_rad = lat1 * RAD_PER_DEG
        lng1_rad = lng1 * RAD_PER_DEG

        lat2_rad = lat2 * RAD_PER_DEG
        lng2_rad = lng2 * RAD_PER_DEG

        a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlng_rad/2))**2
        c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))

        dNm = Rnm * c

  return dNm

end

