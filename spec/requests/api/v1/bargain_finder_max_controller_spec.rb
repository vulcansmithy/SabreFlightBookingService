require "rails_helper"

describe Api::V1::BargainFinderMaxController do
  
  it "should be able to successfully call the BargainFinderMax API endpoint and return a set of itineraries" do
    
    # establish a new Sabre session
    post "/api/sabre_session/create_session"
    expect(response.code).to eq "201"

    # setup the payload
    payload = { 
      sabre_session_token:            JSON.parse(response.body)["binary_security_token"],
      origin_and_destination:         [{ departure_date_time: "2016-06-05T00:00:00", origin_location: "MNL",  destination_location:  "SIN" }],
      passenger_types_and_quantities: [{ passenger_type: "ADT", quantity: 1 }, { passenger_type: "CNN", quantity: 1 }, { passenger_type: "INF", quantity:1 }]
    }
    
    # call the Bargain Finder Max API endpoint
    get "/api/bargain_finder_max/execute_bargain_finder_max_one_way", payload
    expect(response.code).to eq "200"
    
    priced_itineraries = JSON.parse(response.body)["priced_itineraries"]
    expect(priced_itineraries.nil?).to eq false
    
    puts "@DEBUG #{__LINE__}    #{ap priced_itineraries}"
  end

end
