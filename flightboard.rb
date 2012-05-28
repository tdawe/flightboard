require 'sinatra'
require 'vatsim'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.db")
DataMapper::Property::String.length(255)

class Pilot
  include DataMapper::Resource
  property :callsign, String, :key => true
  property :cid, String 
  property :realname, String 
  property :clienttype, String 
  property :latitude, String 
  property :longitude, String 
  property :altitude, String 
  property :groundspeed, String 
  property :planned_aircraft, String 
  property :planned_tascruise, String 
  property :planned_depairport, String 
  property :planned_altitude, String 
  property :planned_destairport, String 
  property :server, String 
  property :protrevision, String 
  property :rating, String 
  property :transponder, String 
  property :planned_revision, String 
  property :planned_flighttype, String 
  property :planned_deptime, String
  property :planned_actdeptime, String
  property :planned_hrsenroute, String 
  property :planned_minenroute, String 
  property :planned_hrsfuel, String 
  property :planned_minfuel, String 
  property :planned_altairport, String 
  property :planned_remarks, String 
  property :planned_route, String 
  property :planned_depairport_lat, String 
  property :planned_depairport_lon, String 
  property :planned_destairport_lat, String 
  property :planned_destairport_lon, String 
  property :time_logon, String 
  property :heading, String 
  property :QNH_iHg, String 
  property :QNH_Mb, String
end
DataMapper.finalize
DataMapper.auto_migrate!

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
  "<h1><a href=\"/pilots\">#{Pilot.all.length} pilots</a></h1>"
end

get '/pilots' do
  output = ""

  Pilot.all.each { |pilot|
    output += "<a href=\"/pilots/#{pilot.callsign}\">#{pilot.callsign}<br/>"
  }

  output

end

get '/pilots/:callsign' do
  pilot = Pilot.get(params[:callsign])

  output = "<h1>#{pilot.callsign}</h1>"

  output += "<p>#{pilot.planned_depairport} - #{pilot.planned_destairport}</p>"

  output

end

