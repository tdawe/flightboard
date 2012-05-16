require 'sinatra'
require 'vatsim'

get '/' do
  "<h1>#{Vatsim::Data.new.pilots.length} pilots</h1><h1>#{Vatsim::Data.new.atc.length} atc</h1>"
end

