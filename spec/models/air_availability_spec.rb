require "rails_helper"

RSpec.describe AirAvailability, type: :model do
  
  it "should be able to execute OTA_AirAvailLLSRQ request" do
    
    session = SabreSession.new
    session.set_to_non_production
    result = session.establish_session
    
    expect(result[:status]).to eq :success
    
    air_availability = AirAvailability.new
    air_availability.establish_connection(session)
    
    departure_date_time  = "06-05"
    destination_location = "SIN"
    origin_location      = "MNL"
    
    result = air_availability.execute_air_availability(departure_date_time, origin_location, destination_location)
    expect(result[:status]).to eq :success
  end
  
end
