require "rails_helper"
require "benchmark"

RSpec.describe BargainFinderMax, type: :model do

  it "should be able to create a Air Availability request for 'One Way' trip using Bargain Finder Max" do

    session = Session.new
    session.set_to_non_production
    session.establish_session
    
    bfm = BargainFinderMax.new
    bfm.establish_connection(session)

    origins_and_destinations = [
      bfm.build_origin_and_destination("2016-06-05T00:00:00", "MNL", "SIN"),
    ]
    
    passenger_types_and_quantities = [
      bfm.build_passenger_type_and_quantity("ADT", 1),
      bfm.build_passenger_type_and_quantity("CNN", 1),
      bfm.build_passenger_type_and_quantity("INF", 1),
    ]

    result = nil
    elapse_seconds = Benchmark.realtime do  
      result = bfm.air_availability_one_way(origins_and_destinations, passenger_types_and_quantities)
    end  
    puts "@DEBUG #{__LINE__}    elapse_seconds=#{elapse_seconds}"
    
    expect(result.nil?).to   eq false
    expect(result.empty?).to eq false

  end

  it "should be able to create a Air Availability request for 'Return' trip using Bargain Finder Max" do

    session = Session.new
    session.set_to_non_production
    session.establish_session
    
    bfm = BargainFinderMax.new
    bfm.establish_connection(session)
    
    origins_and_destinations = [
      bfm.build_origin_and_destination("2016-06-05T00:00:00", "MNL", "LHR"),
      bfm.build_origin_and_destination("2016-06-05T00:00:00", "LHR", "MNL"),
    ]
    
    passenger_types_and_quantities = [
      bfm.build_passenger_type_and_quantity("ADT", 1),
      bfm.build_passenger_type_and_quantity("CNN", 1),
      bfm.build_passenger_type_and_quantity("INF", 1),
    ]

    result = nil  
    elapse_seconds = Benchmark.realtime do  
      result = bfm.air_availability_return(origins_and_destinations, passenger_types_and_quantities)
    end   
    puts "@DEBUG #{__LINE__}    elapse_seconds=#{elapse_seconds}"

    expect(result.nil?).to   eq false
    expect(result.empty?).to eq false
  end

  it "should be able to create a Air Availability request for multi sector/'Circle' trip using Bargain Finder Max" do

    session = Session.new
    session.set_to_non_production
    session.establish_session
    
    
    bfm = BargainFinderMax.new
    bfm.establish_connection(session)
    
    origins_and_destinations = [
      bfm.build_origin_and_destination("2016-06-05T00:00:00", "MNL", "SIN"),
      bfm.build_origin_and_destination("2016-06-22T00:00:00", "SIN", "CGK"),
      bfm.build_origin_and_destination("2016-06-24T00:00:00", "CGK", "BKK"),
      bfm.build_origin_and_destination("2016-06-28T00:00:00", "BKK", "MNL"),
    ]
    
    passenger_types_and_quantities = [
      bfm.build_passenger_type_and_quantity("ADT", 1),
      bfm.build_passenger_type_and_quantity("CNN", 1),
      bfm.build_passenger_type_and_quantity("INF", 1),
    ]
    
    result = nil  
    elapse_seconds = Benchmark.realtime do    
      result = bfm.air_availability_circle(origins_and_destinations, passenger_types_and_quantities)
    end
    puts "@DEBUG #{__LINE__}    elapse_seconds=#{elapse_seconds}"  
  
    expect(result.nil?).to   eq false
    expect(result.empty?).to eq false
  end
       
end


