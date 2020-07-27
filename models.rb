require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{File.dirname(__FILE__)}/development.db")
DataMapper::Property::String.length(255)

class Pilot
  include DataMapper::Resource
  property :callsign, String, :key => true
  property :active, Boolean, :default => true
  property :locations, Object
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
  property :scheduled_departure_time, String
  property :scheduled_arrival_time, String
  property :estimated_arrival_time, String
  property :arrival_status, String
  property :flight_status, String
  property :plain_text_status, String
  property :distance_traveled, Integer
  property :distance_remaining, Integer 
end
DataMapper.finalize

DataMapper.auto_upgrade!
