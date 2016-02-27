require "rails_helper"

RSpec.describe BookFromAirAvailability, type: :model do

=begin  
  xit "should be able to find :short_sell_rq SOAP operation" do
    
    session = Session.new
    session.set_to_non_production
    session.establish_session
    
    booking = BookFromAirAvailability.new
    booking.establish_connection(session)
    
    expect(booking.available_operations.include?(:short_sell_rq)).to eq true
  end
=end
    
  it "should execute booking" do
    
    session = Session.new
    session.set_to_non_production
    session.establish_session
    
    booking = BookFromAirAvailability.new
    booking.establish_connection(session)
    
    booking.execute_booking
  end
  
end
