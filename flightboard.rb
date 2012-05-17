require 'sinatra'
require 'vatsim'

get '/' do
  data = Vatsim::Data.new

  "<h1><a href=\"/pilots\">#{data.pilots.length} pilots</a></h1><h1>#{data.atc.length} atc</h1>Update: #{data.general['update']}"
end

get '/pilots' do
  pilots = Vatsim::Data.new.pilots
  output = ""

  pilots.each { |pilot|
    output += "<a href=\"/pilots/#{pilot.callsign}\">#{pilot.callsign}<br/>"
  }

  output

end

get '/pilots/:callsign' do
  pilots = Vatsim::Data.new.pilots
  _pilot = nil

  pilots.each { |pilot|
    _pilot = pilot if pilot.callsign.eql? params[:callsign]
  }

  output = "<h1>#{_pilot.callsign}</h1>"

  output += "<p>#{_pilot.planned_depairport} - #{_pilot.planned_destairport}</p>"

  output += "<p>Route: #{_pilot.planned_route}</p>"

  output += "<p>Aircraft: #{_pilot.planned_aircraft}</p>"

  output

end

