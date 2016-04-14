require "rails_helper"

describe Api::V1::BargainFinderMaxController do
  
  it "should be able to successfully call the BargainFinderMax API endpoint and return a set of itineraries" do
    
    # establish a new Sabre session
    post "/api/sabre_session/create_session"
    expect(response.code).to eq "201"

    origins_and_destinations = [
      BargainFinderMax.build_origin_and_destination("2016-06-05T00:00:00", "MNL", "SIN"),
    ]
    
    passenger_types_and_quantities = [
      BargainFinderMax.build_passenger_type_and_quantity("ADT", 1),
      BargainFinderMax.build_passenger_type_and_quantity("CNN", 1),
      BargainFinderMax.build_passenger_type_and_quantity("INF", 1),
    ]

    payload = { 
      sabre_session_token:            JSON.parse(response.body)["binary_security_token"],
      origin_and_destination:         origins_and_destinations,
      passenger_types_and_quantities: passenger_types_and_quantities
    }
    
    # call the Bargain Finder Max API endpoint
    get "/api/bargain_finder_max/execute_bargain_finder_max_one_way", payload
    expect(response.code).to eq "200"
    
    priced_itineraries = JSON.parse(response.body)["priced_itineraries"]
    expect(priced_itineraries.nil?).to eq false
    
    puts "@DEBUG #{__LINE__}    #{ap priced_itineraries}"
  end

end
