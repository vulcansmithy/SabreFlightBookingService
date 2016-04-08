require "rails_helper"

RSpec.describe EnhancedAirBook, type: :model do
  
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
  
end
