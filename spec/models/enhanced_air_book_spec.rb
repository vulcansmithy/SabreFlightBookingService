require "rails_helper"

RSpec.describe EnhancedAirBook, type: :model do
  
=begin  
  it "should be able to execute EnhancedAirBookRQ request" do
    
    session = Session.new
    session.set_to_non_production
    session.establish_session
    
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
=end
  
  it "should be able to execute an EnhancedAirBookRQ request of a 'OneWay' trip type" do

    session = Session.new
    session.set_to_non_production
    session.establish_session
    
    bargain_finder_max = BargainFinderMax.new
    bargain_finder_max.establish_connection(session)
    
    origins_and_destinations = [
      bargain_finder_max.build_origin_and_destination("2016-06-05T00:00:00", "MNL", "SIN"),
    ]
    
    passenger_types_and_quantities = [
      bargain_finder_max.build_passenger_type_and_quantity("ADT", 1),
    ]

    flight_segments = []
    picked_result   = bargain_finder_max.air_availability_one_way(origins_and_destinations, passenger_types_and_quantities).first

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
    puts "@DEBUG #{__LINE__}    #{ap flight_segments}"


    enhanced_air_book = EnhancedAirBook.new
    enhanced_air_book.establish_connection(session)
    
    response = enhanced_air_book.execute_enhanced_air_book(flight_segments: flight_segments)
    expect(response[:status]).to eq :success
  end  
  
end
