require "rails_helper"

describe Api::V1::BargainFinderMaxController do
  
  it "should be able to successfully call the BargainFinderMax API endpoint and return a set of itineraries" do
    
    # establish a new Sabre session
    post "/api/sabre_session/create_session"
    expect(response.code).to eq "201"

    # prepare the origins_and_destinations payload
    origins_and_destinations = [
      BargainFinderMax.build_origin_and_destination("2016-06-05T00:00:00", "MNL", "SIN"),
    ]
    
    # prepare the passenger_types_and_quantities payload
    passenger_types_and_quantities = [
      BargainFinderMax.build_passenger_type_and_quantity("ADT", 1),
      BargainFinderMax.build_passenger_type_and_quantity("CNN", 1),
      BargainFinderMax.build_passenger_type_and_quantity("INF", 1),
    ]

    # consolidate the payload
    payload = { 
      sabre_session_token:            JSON.parse(response.body)["binary_security_token"],
      origin_and_destination:         origins_and_destinations,
      passenger_types_and_quantities: passenger_types_and_quantities
    }
    
    # call the BargainFinderMax API with the corresponding payload
    get "/api/bargain_finder_max/execute_bargain_finder_max_one_way", payload
    
    # make sure the response code is OK or '200'
    expect(response.code).to eq "200"
    
    # retrieved the returned result
    priced_itineraries = JSON.parse(response.body)["priced_itineraries"]
    expect(priced_itineraries.nil?).to eq false
    
    # make sure priced_itineraries is not empty and has a value
    expect(priced_itineraries.empty?).to eq false
    
    air_itinerary = (priced_itineraries.first)["air_itinerary"]
    expect(air_itinerary.nil?).to eq false
    
    origin_destination_options = air_itinerary["origin_destination_options"]
    expect(origin_destination_options.nil?).to eq false
    
    origin_destination_option = origin_destination_options["origin_destination_option"]
    expect(origin_destination_option.nil?).to eq false
    
    flight_segment = origin_destination_option["flight_segment"]
    expect(flight_segment.nil?).to eq false
  end

end
