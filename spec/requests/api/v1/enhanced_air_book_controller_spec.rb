require "rails_helper"

describe Api::V1::EnhancedAirBookController do

=begin  
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
    
    # call the EnhancedAirBook API endpoint
    post "/api/enhanced_air_book/execute_enhanced_air_book", payload
    expect(response.code).to eq "201"
    
    returned_data = JSON.parse(response.body)
    expect(returned_data.nil?).to eq false
    
    expect(returned_data["ota_air_book_rs"         ].nil?).to eq false
    expect(returned_data["travel_itinerary_read_rs"].nil?).to eq false
  end
=end
    
  it "should be able to do a BargainFinderMax, PassengerDetail and finally do a EnhancedAirBook API request" do
    
    # establish a new Sabre session
    post "/api/sabre_session/create_session"
    expect(response.code).to eq "201"
    
    # retrieve the returned binary_security_token
    binary_security_token = JSON.parse(response.body)["binary_security_token"]
    
    # make sure binary_security_token is present and not have nil value
    expect(binary_security_token.nil?).to eq false

    # make sure the binary_security_token has the sub string value 'Shared/IDL:IceSess'  
    expect(binary_security_token.scan(/\AShared\/IDL:IceSess/).empty?).to eq false
    


    
    # prepare the origins_and_destinations payload for BargainFinderMax API
    origins_and_destinations = [
      BargainFinderMax.build_origin_and_destination("2016-06-05T00:00:00", "MNL", "SIN"),
    ]
    
    # prepare the passenger_types_and_quantities payload for BargainFinderMax API
    passenger_types_and_quantities = [
      BargainFinderMax.build_passenger_type_and_quantity("ADT", 1),
    ]

    # consolidate the payload
    payload = { 
      sabre_session_token:            binary_security_token,
      origin_and_destination:         origins_and_destinations,
      passenger_types_and_quantities: passenger_types_and_quantities
    }
    
    # call the BargainFinderMax API with the corresponding payload
    get "/api/bargain_finder_max/execute_bargain_finder_max_one_way", payload

    priced_itineraries = JSON.parse(response.body)["priced_itineraries"]
    expect(priced_itineraries.nil?).to eq false  
    
    picked_result = priced_itineraries.first 
    expect(picked_result.nil?).to eq false
  
    flight_segments = []
    BargainFinderMax.extract_air_itinerary_for_api(picked_result["air_itinerary"]).each do |origin_destionation_option|
      flight_segments << EnhancedAirBook.build_flight_segment_origin_destination_information(
        :@DepartureDateTime               => BargainFinderMax.extract_departure_date_time_for_api(origin_destionation_option),
        :@FlightNumber                    => BargainFinderMax.extract_flight_number_for_api(origin_destionation_option),
        :@NumberInParty                   => passenger_types_and_quantities.size,
        :@ResBookDesigCode                => BargainFinderMax.extract_res_book_desig_code_for_api(origin_destionation_option), 
        :@Status                          => "NN",
        :@LocationCodeDestinationLocation => BargainFinderMax.extract_location_code_destination_location_for_api(origin_destionation_option),
        :@CodeMarketingAirline            => BargainFinderMax.extract_code_marketing_airline_for_api(origin_destionation_option), 
        :@LocationCodeOriginLocation      => BargainFinderMax.extract_location_code_origin_location_for_api(origin_destionation_option),
      )
    end
  

    
    # prepare the document_advance_passenger payload for PassengerDetail API
    document_advance_passenger = PassengerDetail.build_advance_passenger_document_section(
      :@ExpirationDate    => "2018-05-26", 
      :@Number            => "1234567890",
      :@Type              => "P",
      :IssueCountry       => "FR",
      :NationalityCountry => "FR"
    ) 
    
    # prepare the person_name_advance_passenger payload for PassengerDetail API
    person_name_advance_passenger = PassengerDetail.build_advance_passenger_person_name_section(
      :@DateOfBirth       => "1980-12-02",
      :@DocumentHolder    => "true",
      :@Gender            => "M", 
      :@NameNumber        => "1.1",
      :GivenName          => "Charles",
      :MiddleName         => "Cambell",
      :Surname            => "Finley", 
    )
    
    # prepare the contact_number_contact_info payload for PassengerDetail API
    contact_number_contact_info  = PassengerDetail.build_contact_info_contact_number_section(
      :@NameNumber        => "1.1",
      :@Phone             => "817-555-1212",
      :@PhoneUseType      => "H",  
    )
    
    # prepare the person_name_contact_info payload for PassengerDetail API
    person_name_contact_info = PassengerDetail.build_contact_info_person_name_section(
      :@Infant        => "false", 
      :@NameNumber    => "1.1",
      :@PassengerType => "ADT",
      :GivenName      => person_name_advance_passenger[:GivenName],
      :Surname        => person_name_advance_passenger[:Surname  ],
    ) 
    
    payload = {
      :sabre_session_token           => binary_security_token,
      :document_advance_passenger    => document_advance_passenger,
      :person_name_advance_passenger => person_name_advance_passenger, 
      :contact_number_contact_info   => contact_number_contact_info,
      :person_name_contact_info      => person_name_contact_info, 
    }
    
    # call the PassengerDetail API endpoint
    post "/api/passenger_detail/execute_passenger_detail", payload
    expect(response.code).to eq "201"
    
    returned_data = JSON.parse(response.body)
    expect(returned_data.nil?).to eq false
    
    customer_info = returned_data["customer_info"]
    expect(customer_info.nil?).to eq false

    # make sure the returned_data contains the one passed to the API  
    expect((customer_info["person_name"])["given_name"]).to eq "CHARLES"
    expect((customer_info["person_name"])["surname"   ]).to eq "FINLEY"
    
    
    
    # prepare payload for EnhancedAirBook API
    payload = {
      :sabre_session_token => binary_security_token,
      :flight_segments     => flight_segments
    }
    
    # call the EnhancedAirBook API endpoint
    post "/api/enhanced_air_book/execute_enhanced_air_book", payload
    expect(response.code).to eq "201"
    
    returned_data = JSON.parse(response.body)
    expect(returned_data.nil?).to eq false
    
    expect(returned_data["ota_air_book_rs"         ].nil?).to eq false
    expect(returned_data["travel_itinerary_read_rs"].nil?).to eq false
  end

end
