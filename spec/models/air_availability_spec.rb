require "rails_helper"

RSpec.describe AirAvailability, type: :model do
  
  it "should be able to execute OTA_AirAvailLLSRQ request" do
    
    session = Session.new
    session.set_to_non_production
    session.establish_session
    
    air_availability = AirAvailability.new
    air_availability.establish_connection(session)
    
    departure_date_time  = "06-05"
    destination_location = "SIN"
    origin_location      = "MNL"
    
    result = air_availability.execute_air_availability(departure_date_time, origin_location, destination_location)
    puts "@DEBUG #{__LINE__}    #{ap result}"
  end
  
end
