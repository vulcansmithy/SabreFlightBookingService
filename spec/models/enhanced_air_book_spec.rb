require "rails_helper"

RSpec.describe EnhancedAirBook, type: :model do
  
  it "should be able to execute EnhancedAirBookRQ request" do
    
    session = SabreSession.new
    session.set_to_non_production
    result = session.establish_session
    
    expect(result[:status]).to eq :success
    
    enhanced_air_book = EnhancedAirBook.new
    enhanced_air_book.establish_connection(session)
    
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
    
    response = enhanced_air_book.execute_enhanced_air_book(flight_segments: flight_segments)
    expect(response[:status]).to eq :success
  end  
  
  it "should be able to execute an EnhancedAirBookRQ request of a 'OneWay' trip type" do

    session = SabreSession.new
    session.set_to_non_production
    result = session.establish_session
    
    expect(result[:status]).to eq :success
  
  
    ##
    ## Do a BargainFinderMax
    ##   
    bargain_finder_max = BargainFinderMax.new
    bargain_finder_max.establish_connection(session)
    
    origins_and_destinations = [
      BargainFinderMax.build_origin_and_destination("2016-06-05T00:00:00", "MNL", "SIN"),
    ]
    
    passenger_types_and_quantities = [
      BargainFinderMax.build_passenger_type_and_quantity("ADT", 1),
    ]

    flight_segments = []
    picked_result   = (bargain_finder_max.air_availability_one_way(origins_and_destinations, passenger_types_and_quantities))[:data][:priced_itineraries].first

    BargainFinderMax.extract_air_itinerary(picked_result[:air_itinerary]).each do |origin_destionation_option|
      flight_segments << EnhancedAirBook.build_flight_segment_origin_destination_information(
        :@DepartureDateTime               =>  bargain_finder_max.extract_departure_date_time(origin_destionation_option),
        :@FlightNumber                    =>  bargain_finder_max.extract_flight_number(origin_destionation_option),
        :@NumberInParty                   =>  passenger_types_and_quantities.size,
        :@ResBookDesigCode                =>  bargain_finder_max.extract_res_book_desig_code(origin_destionation_option), 
        :@Status                          =>  "NN",
        :@LocationCodeDestinationLocation => bargain_finder_max.extract_location_code_destination_location(origin_destionation_option),
        :@CodeMarketingAirline            => bargain_finder_max.extract_code_marketing_airline(origin_destionation_option), 
        :@LocationCodeOriginLocation      => bargain_finder_max.extract_location_code_origin_location(origin_destionation_option),
      )
    end



    ##
    ## Do a PassengerDetail
    ##
    passenger_detail = PassengerDetail.new
    passenger_detail.establish_connection(session)
    
    document_advance_passenger = PassengerDetail.build_advance_passenger_document_section(
      :@ExpirationDate    => "2018-05-26", 
      :@Number            => "1234567890",
      :@Type              => "P",
      :IssueCountry       => "FR",
      :NationalityCountry => "FR"
    )  

    person_name_advance_passenger = PassengerDetail.build_advance_passenger_person_name_section(
      :@DateOfBirth       => "1980-12-02",
      :@DocumentHolder    => "true",
      :@Gender            => "M", 
      :@NameNumber        => "1.1",
      :GivenName          => "Charles",
      :MiddleName         => "Cambell",
      :Surname            => "Finley", 
    )

    contact_number_contact_info  = PassengerDetail.build_contact_info_contact_number_section(
      :@NameNumber        => "1.1",
      :@Phone             => "817-555-1212",
      :@PhoneUseType      => "H",  
    )

    person_name_contact_info = PassengerDetail.build_contact_info_person_name_section(
      :@Infant        => "false", 
      :@NameNumber    => "1.1",
      :@PassengerType => "ADT",
      :GivenName      => person_name_advance_passenger[:GivenName],
      :Surname        => person_name_advance_passenger[:Surname  ],
    ) 
    
    passenger_detail_result = passenger_detail.execute_passenger_detail(
      :document_advance_passenger    => document_advance_passenger,
      :person_name_advance_passenger => person_name_advance_passenger,
      :contact_number_contact_info   => contact_number_contact_info,
      :person_name_contact_info      => person_name_contact_info
    )



    ##
    ## Do a EnhancedAirBook
    ##
    enhanced_air_book = EnhancedAirBook.new
    enhanced_air_book.establish_connection(session)
    
    response = enhanced_air_book.execute_enhanced_air_book(flight_segments: flight_segments)
    expect(response[:status]).to eq :success
  end  
  
end
