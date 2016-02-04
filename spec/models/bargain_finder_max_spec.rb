require "rails_helper"

RSpec.describe BargainFinderMax, type: :model do
  
  it "should do something" do
    session = Session.new
    session.create_session_token
    
    origin_destination_information = {
      "departure_date_time"  => "",
      "origin_location"      => "",
      "destination_location" => "",
    }
    
    
    bfm = BargainFinderMax.new
    result = bfm.bfm_one_way(session, origin_destination_information)
  end

end
