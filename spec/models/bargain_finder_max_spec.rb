require "rails_helper"

RSpec.describe BargainFinderMax, type: :model do

  it "should be able to create a Air Availability request for 'One Way' trip using Bargain Finder Max" do
    session = Session.new
    session.create_session_token
    
    origins_and_destinations = [
      {
        :departure_date_time  => "2016-02-14T00:00:00",
        :origin_location      => "MNL",
        :destination_location => "SIN",
      },
    ]
    
    passenger_types_and_quantities = [
      {
        :passenger_type => "ADT",
        :quantity       => 1,
      },
      {
        :passenger_type => "CNN",
        :quantity       => 1, 
      },
      {
        :passenger_type => "INF",
        :quantity       => 1,
      },
    ]
    
    bfm    = BargainFinderMax.new
    result = bfm.bfm_one_way(session, origins_and_destinations, passenger_types_and_quantities)
  end

  it "should be able to create a Air Availability request for 'Return' trip using Bargain Finder Max" do
    session = Session.new
    session.create_session_token
    
    origins_and_destinations = [
      {
        :departure_date_time  => "2016-02-14T00:00:00",
        :origin_location      => "MNL",
        :destination_location => "LHR",
      },
      {
        :departure_date_time  => "2016-02-14T00:00:00",
        :origin_location      => "LHR",
        :destination_location => "MNL",
      },
    ]
    
    passenger_types_and_quantities = [
      {
        :passenger_type => "ADT",
        :quantity       => 1,
      },
      {
        :passenger_type => "CNN",
        :quantity       => 1, 
      },
      {
        :passenger_type => "INF",
        :quantity       => 1,
      },
    ]
    
    bfm    = BargainFinderMax.new
    result = bfm.bfm_return(session, origins_and_destinations, passenger_types_and_quantities)
  end

  it "should be able to create a Air Availability request for multi sector/'Circle' trip using Bargain Finder Max" do
    session = Session.new
    session.create_session_token
    
    origins_and_destinations = [
      {
        :departure_date_time  => "2016-02-14T00:00:00",
        :origin_location      => "MNL",
        :destination_location => "SIN",
      },
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
    ]
    
    passenger_types_and_quantities = [
      {
        :passenger_type => "ADT",
        :quantity       => 1,
      },
      {
        :passenger_type => "CNN",
        :quantity       => 1, 
      },
      {
        :passenger_type => "INF",
        :quantity       => 1,
      },
    ]
    
    bfm    = BargainFinderMax.new
    result = bfm.bfm_circle(session, origins_and_destinations, passenger_types_and_quantities)
  end

end
