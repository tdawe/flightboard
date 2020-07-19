require 'spec_helper'

describe "Sinatra App" do
  
  before(:all) do
    WebMock.disable_net_connect!
    File.delete(Vatsim::Data::STATUS_FILE_PATH) if File.exists?(Vatsim::Data::STATUS_FILE_PATH)
    File.delete(Vatsim::Data::DATA_FILE_PATH) if File.exists?(Vatsim::Data::DATA_FILE_PATH)
    stub_request(:get, "http://status.vatsim.net/status.txt").to_return(:body => File.new(File.dirname(__FILE__) + "/vatsim-status.txt"))
    stub_request(:get, "http://www.net-flyer.net/DataFeed/vatsim-data.txt").to_return(:body => File.new(File.dirname(__FILE__) + "/vatsim-data.txt"))
    stub_request(:get, "http://www.klain.net/sidata/vatsim-data.txt").to_return(:body => File.new(File.dirname(__FILE__) + "/vatsim-data.txt"))
    stub_request(:get, "http://fsproshop.com/servinfo/vatsim-data.txt").to_return(:body => File.new(File.dirname(__FILE__) + "/vatsim-data.txt"))
    stub_request(:get, "http://info.vroute.net/vatsim-data.txt").to_return(:body => File.new(File.dirname(__FILE__) + "/vatsim-data.txt"))
    stub_request(:get, "http://data.vattastic.com/vatsim-data.txt").to_return(:body => File.new(File.dirname(__FILE__) + "/vatsim-data.txt")) 
    refreshdata
  end

  it "should respond to GET with correct number of pilots and airports" do
    get '/'
    last_response.should be_ok
    last_response.body.should include("376 pilots")
    last_response.body.should include("281 airports")
  end

end
