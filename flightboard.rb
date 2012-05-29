require 'sinatra'
require 'vatsim'
require 'data_mapper'
require 'haml'

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
      Pilot.create(:callsign => pilot.callsign, :cid => pilot.cid, :realname => pilot.realname, :clienttype => pilot.clienttype, :latitude => 	     pilot.latitude, :longitude => pilot.longitude, :altitude => pilot.altitude, :groundspeed => pilot.groundspeed, :planned_aircraft =>           pilot.planned_aircraft, :planned_tascruise => pilot.planned_tascruise, :planned_depairport => pilot.planned_depairport, :planned_altitude => pilot.planned_altitude, :planned_destairport => pilot.planned_destairport, :server => pilot.server, :protrevision => pilot.protrevision, :rating => pilot.rating, :transponder => pilot.transponder, :planned_revision => pilot.planned_revision, :planned_flighttype => pilot.planned_flighttype, :planned_deptime => pilot.planned_deptime, :planned_actdeptime => pilot.planned_actdeptime, :planned_hrsenroute => pilot.planned_minenroute, :planned_hrsfuel => pilot.planned_minfuel, :planned_altairport => pilot.planned_altairport, :planned_remarks => pilot.planned_remarks, :planned_route => pilot.planned_route, :planned_depairport_lat => pilot.planned_depairport_lat, :planned_depairport_lon => pilot.planned_depairport_lon, :planned_destairport_lat => pilot.planned_destairport_lat, :planned_destairport_lon => pilot.planned_destairport_lon, :time_logon => pilot.time_logon, :heading => pilot.heading, :QNH_iHg => pilot.QNH_iHg, :QNH_Mb => pilot.QNH_Mb)
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
  @arrivals = Pilot.all(:planned_destairport => params[:icao])
  @departures = Pilot.all(:planned_depairport => params[:icao])
  haml :airport
end

