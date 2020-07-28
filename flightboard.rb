require 'sinatra'
require 'sinatra/content_for'
require 'haml'
require 'vatsim'
require 'logger'
require File.dirname(__FILE__) + '/models.rb'

$stdout.sync = true
@logger = Logger.new(STDOUT)

Thread.new do # trivial example work thread
  while true do
     refreshdata
     sleep 120
  end
end

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.db")
DataMapper::Property::String.length(255)

require './models.rb'

DataMapper.auto_upgrade!

def refreshdata
  output = ""
  data = Vatsim::Data.new
  start = Time.now
  Pilot.transaction do
    now = Time.parse("#{data.general['update']}Z")
    #Pilot.destroy
    @logger.info("Set all pilots to inactive")
    Pilot.update(:active => false)
    @logger.info("All pilots set to inactive")
      
    @logger.info("Iterating through active pilots")
    data.pilots.each { |pilot|
      _scheduled_departure_time = scheduled_departure_time now, pilot
      _scheduled_arrival_time = scheduled_arrival_time now, pilot
      _estimated_arrival_time = estimated_arrival_time now, pilot
      _arrival_status = arrival_status now, pilot
      _flight_status = flight_status pilot
      _plain_text_status = plain_text_status pilot
      _distance_traveled = distance_traveled pilot
      _distance_remaining = distance_remaining pilot
      
      @found_pilot = Pilot.get(pilot.callsign)
      if !@found_pilot.nil?
         @logger.info("Found pilot #{pilot.callsign}")
         locations = @found_pilot.locations
         locations = locations.push([pilot.latitude.to_f, pilot.longitude.to_f])
         Pilot.first_or_create({:callsign => pilot.callsign}).update(:callsign => pilot.callsign, :active => true, :locations => locations, :cid => pilot.cid, :realname => pilot.realname, :clienttype => pilot.clienttype, :latitude => pilot.latitude, :longitude => pilot.longitude, :altitude => pilot.altitude, :groundspeed => pilot.groundspeed, :planned_aircraft => pilot.planned_aircraft, :planned_tascruise => pilot.planned_tascruise, :planned_depairport => pilot.planned_depairport, :planned_altitude => pilot.planned_altitude, :planned_destairport => pilot.planned_destairport, :server => pilot.server, :protrevision => pilot.protrevision, :rating => pilot.rating, :transponder => pilot.transponder, :planned_revision => pilot.planned_revision, :planned_flighttype => pilot.planned_flighttype, :planned_deptime => pilot.planned_deptime, :planned_actdeptime => pilot.planned_actdeptime, :planned_hrsenroute => pilot.planned_minenroute, :planned_hrsfuel => pilot.planned_minfuel, :planned_altairport => pilot.planned_altairport, :planned_remarks => pilot.planned_remarks, :planned_route => pilot.planned_route, :planned_depairport_lat => pilot.planned_depairport_lat, :planned_depairport_lon => pilot.planned_depairport_lon, :planned_destairport_lat => pilot.planned_destairport_lat, :planned_destairport_lon => pilot.planned_destairport_lon, :time_logon => pilot.time_logon, :heading => pilot.heading, :QNH_iHg => pilot.QNH_iHg, :QNH_Mb => pilot.QNH_Mb, :scheduled_departure_time => _scheduled_departure_time, :scheduled_arrival_time => _scheduled_arrival_time, :estimated_arrival_time => _estimated_arrival_time, :arrival_status => _arrival_status, :flight_status => _flight_status, :plain_text_status => _plain_text_status, :distance_traveled => _distance_traveled, :distance_remaining => _distance_remaining)
          @found_pilot.save
      else
         @logger.info("Creating pilot #{pilot.callsign}")
        locations = [[pilot.latitude.to_f, pilot.longitude.to_f]]
        Pilot.create(:callsign => pilot.callsign, :active => true, :locations => locations, :cid => pilot.cid, :realname => pilot.realname, :clienttype => pilot.clienttype, :latitude => pilot.latitude, :longitude => pilot.longitude, :altitude => pilot.altitude, :groundspeed => pilot.groundspeed, :planned_aircraft =>           pilot.planned_aircraft, :planned_tascruise => pilot.planned_tascruise, :planned_depairport => pilot.planned_depairport, :planned_altitude => pilot.planned_altitude, :planned_destairport => pilot.planned_destairport, :server => pilot.server, :protrevision => pilot.protrevision, :rating => pilot.rating, :transponder => pilot.transponder, :planned_revision => pilot.planned_revision, :planned_flighttype => pilot.planned_flighttype, :planned_deptime => pilot.planned_deptime, :planned_actdeptime => pilot.planned_actdeptime, :planned_hrsenroute => pilot.planned_minenroute, :planned_hrsfuel => pilot.planned_minfuel, :planned_altairport => pilot.planned_altairport, :planned_remarks => pilot.planned_remarks, :planned_route => pilot.planned_route, :planned_depairport_lat => pilot.planned_depairport_lat, :planned_depairport_lon => pilot.planned_depairport_lon, :planned_destairport_lat => pilot.planned_destairport_lat, :planned_destairport_lon => pilot.planned_destairport_lon, :time_logon => pilot.time_logon, :heading => pilot.heading, :QNH_iHg => pilot.QNH_iHg, :QNH_Mb => pilot.QNH_Mb, :scheduled_departure_time => _scheduled_departure_time, :scheduled_arrival_time => _scheduled_arrival_time, :estimated_arrival_time => _estimated_arrival_time, :arrival_status => _arrival_status, :flight_status => _flight_status, :plain_text_status => _plain_text_status, :distance_traveled => _distance_traveled, :distance_remaining => _distance_remaining)
      end
    }
  end
  @logger.info("Loaded #{Pilot.all.length} pilots")
  @logger.info("Took #{Time.now - start} seconds to update")
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
  @airports = {} #Array.new
  pilots.each { |pilot|
    if pilot.active?
      @airports[pilot.planned_depairport] = 0 if !@airports[pilot.planned_depairport]
      @airports[pilot.planned_destairport] = 0 if !@airports[pilot.planned_destairport]
      @airports[pilot.planned_depairport] = @airports[pilot.planned_depairport] + 1
      @airports[pilot.planned_destairport] = @airports[pilot.planned_destairport] + 1
      #@airports << pilot.planned_depairport if !@airports.include?(pilot.planned_depairport)
      #@airports << pilot.planned_destairport if !@airports.include?(pilot.planned_destairport)
    end
  }
  @airports = @airports.sort_by {|airport, movements| 0 - movements }
  haml :airports
end

get '/airports/:icao' do
  @arrivals = Pilot.all(:active => true, :planned_destairport => params[:icao], :order => [:scheduled_arrival_time.asc])
  @departures = Pilot.all(:active => true, :planned_depairport => params[:icao], :order => [:scheduled_departure_time.asc])
  haml :airport
end


get '/pilots/:callsign/status.json' do
  @pilot = Pilot.get(params[:callsign])

  @pilot.scheduled_departure_time = @pilot.scheduled_departure_time.nil? ? "" : Time.parse(@pilot.scheduled_departure_time).strftime("%R %Z")
  @pilot.scheduled_arrival_time = @pilot.scheduled_arrival_time.nil? ? "" : Time.parse(@pilot.scheduled_arrival_time).strftime("%R %Z")
  @pilot.estimated_arrival_time = @pilot.estimated_arrival_time.nil? ? "" : Time.parse(@pilot.estimated_arrival_time).strftime("%R %Z")

  @pilot.to_json
end

get '/airports/:icao/arrivals.json' do
  @arrivals = Pilot.all(:active => true, :planned_destairport => params[:icao], :order => [:distance_remaining.asc])

  @arrivals.each { |arrival|
    arrival.scheduled_departure_time = arrival.scheduled_departure_time.nil? ? "" : Time.parse(arrival.scheduled_departure_time).strftime("%R %Z")
    arrival.scheduled_arrival_time = arrival.scheduled_arrival_time.nil? ? "" : Time.parse(arrival.scheduled_arrival_time).strftime("%R %Z")
    arrival.estimated_arrival_time = arrival.estimated_arrival_time.nil? ? "" : Time.parse(arrival.estimated_arrival_time).strftime("%R %Z")
  }
  @arrivals.to_json
end

get '/airports/:icao/departures.json' do
  @departures = Pilot.all(:active => true, :planned_depairport => params[:icao], :order => [:distance_traveled.asc])
  @departures.each { |departure|
    departure.scheduled_departure_time = departure.scheduled_departure_time.nil? ? "" : Time.parse(departure.scheduled_departure_time).strftime("%R %Z")
    departure.scheduled_arrival_time = departure.scheduled_arrival_time.nil? ? "" : Time.parse(departure.scheduled_arrival_time).strftime("%R %Z")
    departure.estimated_arrival_time = departure.estimated_arrival_time.nil? ? "" : Time.parse(departure.estimated_arrival_time).strftime("%R %Z")
  }
  @departures.to_json
end
##############################333

def scheduled_departure_time now, pilot
  departure_time = pilot.planned_deptime.eql?("0") ? nil : pilot.planned_deptime
  #handles invalid times
  departure_time = nil if pilot.planned_deptime.to_i > 2359

  if !departure_time.nil?
    hours = (pilot.planned_deptime.to_i / 100).to_i;
    minutes = pilot.planned_deptime.to_i - ((pilot.planned_deptime.to_i / 100).to_i * 100)
    hours = 0 if hours > 23
    minutes = 0 if minutes > 59
    departure_time = Time.gm(now.year, now.month, now.day, hours, minutes)
  end

  return departure_time
end

def scheduled_arrival_time now, pilot
  deptime = scheduled_departure_time now, pilot
  return deptime if deptime.nil?
  return deptime + (pilot.planned_hrsenroute.to_i * 60*60) + (pilot.planned_minenroute.to_i*60)
end

def estimated_arrival_time now, pilot
  _flight_status = flight_status(pilot)
  return nil if(!(_flight_status.eql?("On the way") or _flight_status.eql?("Arriving"))) # or !_flight_status.eql?("Arriving"))
  return nil if pilot.planned_destairport_lat.eql?("0")
  distance = haversine_distance(pilot.latitude.to_f, pilot.longitude.to_f, pilot.planned_destairport_lat.to_f, pilot.planned_destairport_lon.to_f)
  return nil if pilot.groundspeed.to_i == 0
  time_for_distance = distance / pilot.groundspeed.to_i
  return now.getgm + (time_for_distance * 60 * 60)
end

def flight_status pilot
  status = "On the way"
  distance_from_depairport = haversine_distance(pilot.latitude.to_f, pilot.longitude.to_f, pilot.planned_depairport_lat.to_f, pilot.planned_depairport_lon.to_f)
  distance_from_destairport = haversine_distance(pilot.latitude.to_f, pilot.longitude.to_f, pilot.planned_destairport_lat.to_f, pilot.planned_destairport_lon.to_f)
  status = "Boarding" if distance_from_depairport < 5 and pilot.groundspeed.to_i == 0
  status = "Left Gate" if distance_from_depairport < 5 and pilot.groundspeed.to_i > 0
  status = "Departing" if distance_from_depairport < 25 and pilot.groundspeed.to_i > 0
  status = "Arriving" if distance_from_destairport < 50 and pilot.groundspeed.to_i > 0
  status = "Taxiing to Gate" if distance_from_destairport < 5 and pilot.groundspeed.to_i < 50
  status = "At Gate" if distance_from_destairport < 5 and pilot.groundspeed.to_i == 0
  status
end

def arrival_status now, pilot
  status = "On Time"

  distance_from_depairport = haversine_distance(pilot.latitude.to_f, pilot.longitude.to_f, pilot.planned_depairport_lat.to_f, pilot.planned_depairport_lon.to_f)

  return "N/A" if scheduled_arrival_time(now, pilot).nil? or estimated_arrival_time(now, pilot).nil?
  status = "Late" if estimated_arrival_time(now, pilot) > scheduled_arrival_time(now, pilot)
  status = "Early" if estimated_arrival_time(now, pilot) < scheduled_arrival_time(now, pilot)
  return status
end

def distance_traveled pilot
  return haversine_distance(pilot.latitude.to_f, pilot.longitude.to_f, pilot.planned_depairport_lat.to_f, pilot.planned_depairport_lon.to_f).round(0)
end

def distance_remaining pilot
  return haversine_distance(pilot.latitude.to_f, pilot.longitude.to_f, pilot.planned_destairport_lat.to_f, pilot.planned_destairport_lon.to_f).round(0)
end

def plain_text_status pilot
  distance_from_depairport = haversine_distance(pilot.latitude.to_f, pilot.longitude.to_f, pilot.planned_depairport_lat.to_f, pilot.planned_depairport_lon.to_f).round(0)
  distance_to_destairport = haversine_distance(pilot.latitude.to_f, pilot.longitude.to_f, pilot.planned_destairport_lat.to_f, pilot.planned_destairport_lon.to_f).round(0)
  groundspeed = pilot.groundspeed
  altitude = pilot.altitude

  return "Traveled: #{distance_from_depairport} Remaining: #{distance_to_destairport} Speed: #{groundspeed} Altitude: #{altitude}"
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

