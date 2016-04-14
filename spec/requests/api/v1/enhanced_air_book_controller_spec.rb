require "rails_helper"

describe Api::V1::EnhancedAirBookController do
  
  it "should be able to successfully call the EnhancedAirBook API endpoint" do
    
    # establish a new Sabre session
    post "/api/sabre_session/create_session"
    expect(response.code).to eq "201"

    flight_segments = []
    flight_segments << EnhancedAirBook.build_flight_segment_origin_destination_information(
      :@DepartureDateTime               => "2016-06-05T17:05:00",
      :@FlightNumber                    => "764",
      :@NumberInParty                   => "1",
      :@ResBookDesigCode                => "H",
      :@Status                          => "NN",
      :@LocationCodeDestinationLocation => "SIN",
      :@CodeMarketingAirline            => "3K",
      :@LocationCodeOriginLocation      => "MNL",
    )
    
    payload = {
      :sabre_session_token => JSON.parse(response.body)["binary_security_token"],
      :flight_segments     => flight_segments
    }
    
    # call the Passenger Detail API endpoint
    post "/api/enhanced_air_book/execute_enhanced_air_book", payload
    expect(response.code).to eq "201"
    
    enhanced_air_book = JSON.parse(response.body)["enhanced_air_book"]
    expect(enhanced_air_book.nil?).to eq false
    
    puts "@DEBUG #{__LINE__}    #{ap enhanced_air_book}"
  end

end
