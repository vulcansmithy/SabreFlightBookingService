require "rails_helper"

RSpec.describe PassengerDetail, type: :model do
  
  it "should be able to receive :passenger_details_rq when executing available_operations" do
    
    session = Session.new
    session.set_to_non_production
    session.establish_session
    
    passenger_detail = PassengerDetail.new
    passenger_detail.establish_connection(session)
    
    expect(passenger_detail.available_operations.first).to eq :passenger_details_rq
  end  

  it "should be able to execute a PassengerDetailRQ" do
    
    session = Session.new
    session.set_to_non_production
    session.establish_session
    
    passenger_detail = PassengerDetail.new
    passenger_detail.establish_connection(session)
    
    passenger_detail.execute_passenger_detail
  end  
  
end
