require 'sinatra'
require 'haml'
require File.dirname(__FILE__) + '/models.rb'

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

