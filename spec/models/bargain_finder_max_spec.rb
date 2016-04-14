require "rails_helper"
require "benchmark"

RSpec.describe BargainFinderMax, type: :model do

  it "should be able to create a Air Availability request for 'One Way' trip using Bargain Finder Max" do

    session = SabreSession.new
    session.set_to_non_production
    result = session.establish_session
    
    expect(result[:status]).to eq :success
    
    origins_and_destinations = [
      BargainFinderMax.build_origin_and_destination("2016-06-05T00:00:00", "MNL", "SIN"),
    ]
    
    passenger_types_and_quantities = [
      BargainFinderMax.build_passenger_type_and_quantity("ADT", 1),
      BargainFinderMax.build_passenger_type_and_quantity("CNN", 1),
      BargainFinderMax.build_passenger_type_and_quantity("INF", 1),
    ]

    bargain_finder_max = BargainFinderMax.new
    bargain_finder_max.establish_connection(session)

    result = nil
    elapse_seconds = Benchmark.realtime do  
      result = bargain_finder_max.air_availability_one_way(origins_and_destinations, passenger_types_and_quantities)
    end  
    puts "@DEBUG #{__LINE__}    elapse_seconds=#{elapse_seconds}"
    
    expect(result.nil?).to   eq false
    expect(result.empty?).to eq false
  end
  
  it "should be able to create a Air Availability request for 'Return' trip using Bargain Finder Max" do

    session = SabreSession.new
    session.set_to_non_production
    session.establish_session
    result = session.establish_session
    
    expect(result[:status]).to eq :success    
    
    origins_and_destinations = [
      BargainFinderMax.build_origin_and_destination("2016-06-05T00:00:00", "MNL", "LHR"),
      BargainFinderMax.build_origin_and_destination("2016-06-05T00:00:00", "LHR", "MNL"),
    ]
    
    passenger_types_and_quantities = [
      BargainFinderMax.build_passenger_type_and_quantity("ADT", 1),
      BargainFinderMax.build_passenger_type_and_quantity("CNN", 1),
      BargainFinderMax.build_passenger_type_and_quantity("INF", 1),
    ]
    
    bargain_finder_max = BargainFinderMax.new
    bargain_finder_max.establish_connection(session)
    
    result = nil  
    elapse_seconds = Benchmark.realtime do  
      result = bargain_finder_max.air_availability_return(origins_and_destinations, passenger_types_and_quantities)
    end   
    puts "@DEBUG #{__LINE__}    elapse_seconds=#{elapse_seconds}"

    expect(result[:data][:priced_itineraries].nil?  ).to eq false
    expect(result[:data][:priced_itineraries].empty?).to eq false
  end
    
  it "should be able to create a Air Availability request for multi sector/'Circle' trip using Bargain Finder Max" do

    session = SabreSession.new
    session.set_to_non_production
    result = session.establish_session
    
    expect(result[:status]).to eq :success
    
    origins_and_destinations = [
      BargainFinderMax.build_origin_and_destination("2016-06-05T00:00:00", "MNL", "SIN"),
      BargainFinderMax.build_origin_and_destination("2016-06-22T00:00:00", "SIN", "CGK"),
      BargainFinderMax.build_origin_and_destination("2016-06-24T00:00:00", "CGK", "BKK"),
      BargainFinderMax.build_origin_and_destination("2016-06-28T00:00:00", "BKK", "MNL"),
    ]
    
    passenger_types_and_quantities = [
      BargainFinderMax.build_passenger_type_and_quantity("ADT", 1),
      BargainFinderMax.build_passenger_type_and_quantity("CNN", 1),
      BargainFinderMax.build_passenger_type_and_quantity("INF", 1),
    ]
    
    bargain_finder_max = BargainFinderMax.new
    bargain_finder_max.establish_connection(session)
    
    result = nil  
    elapse_seconds = Benchmark.realtime do    
      result = bargain_finder_max.air_availability_circle(origins_and_destinations, passenger_types_and_quantities)
    end
    puts "@DEBUG #{__LINE__}    elapse_seconds=#{elapse_seconds}"  
  
    expect(result[:data][:priced_itineraries].nil?  ).to eq false
    expect(result[:data][:priced_itineraries].empty?).to eq false
  end
  
  it "should be able to call BargainFinderMax.extract_air_itinerary and return an array of origin_destination_options" do

    session = SabreSession.new
    session.set_to_non_production
    result = session.establish_session
    
    expect(result[:status]).to eq :success
    
    origins_and_destinations = [
      BargainFinderMax.build_origin_and_destination("2016-06-05T00:00:00", "MNL", "SIN"),
    ]
    
    passenger_types_and_quantities = [
      BargainFinderMax.build_passenger_type_and_quantity("ADT", 1),
      BargainFinderMax.build_passenger_type_and_quantity("CNN", 1),
      BargainFinderMax.build_passenger_type_and_quantity("INF", 1),
    ]
    
    bargain_finder_max = BargainFinderMax.new
    bargain_finder_max.establish_connection(session)

    result           = bargain_finder_max.air_availability_one_way(origins_and_destinations, passenger_types_and_quantities)
    target_itinerary = result[:data][:priced_itineraries].first
    extracted_origin_destination_options = BargainFinderMax.extract_air_itinerary(target_itinerary[:air_itinerary])
    
    expect(extracted_origin_destination_options.class).to eq Array
    expect(extracted_origin_destination_options.size).to  eq 1
    
    
    origins_and_destinations = [
      BargainFinderMax.build_origin_and_destination("2016-06-05T00:00:00", "MNL", "SIN"),
      BargainFinderMax.build_origin_and_destination("2016-06-22T00:00:00", "SIN", "CGK"),
      BargainFinderMax.build_origin_and_destination("2016-06-24T00:00:00", "CGK", "BKK"),
      BargainFinderMax.build_origin_and_destination("2016-06-28T00:00:00", "BKK", "MNL"),
    ]
    
    passenger_types_and_quantities = [
      BargainFinderMax.build_passenger_type_and_quantity("ADT", 1),
      BargainFinderMax.build_passenger_type_and_quantity("CNN", 1),
      BargainFinderMax.build_passenger_type_and_quantity("INF", 1),
    ]
    
    result           = bargain_finder_max.air_availability_circle(origins_and_destinations, passenger_types_and_quantities)
    target_itinerary = result[:data][:priced_itineraries].first
    extracted_origin_destination_options = BargainFinderMax.extract_air_itinerary(target_itinerary[:air_itinerary])
    
    expect(extracted_origin_destination_options.class   ).to eq Array
    expect(extracted_origin_destination_options.size > 1).to eq true
  end  

end


