require "rails_helper"

RSpec.describe BargainFinderMax, type: :model do
  
  it "should do something" do
    session = Session.new
    session.create_session_token
    
    origins_and_destinations = [
      {
        :departure_date_time  => "2016-02-14T00:00:00",
        :origin_location      => "MNL",
        :destination_location => "SIN",
      },
=begin  
      {
        :departure_date_time  => "2016-02-22T00:00:00",
        :origin_location      => "SIN",
        :destination_location => "CGK",
      },
      {
        :departure_date_time  => "2016-02-24T00:00:00",
        :origin_location      => "CGK",
        :destination_location => "BKK",
      },
      {
        :departure_date_time  => "2016-02-28T00:00:00",
        :origin_location      => "BKK",
        :destination_location => "MNL",
      },
=end      
    ]
    
    
    bfm = BargainFinderMax.new
    result = bfm.bfm_one_way(session, origins_and_destinations)
  end

end
