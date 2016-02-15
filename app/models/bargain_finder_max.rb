class BargainFinderMax
  
  # == Includes ===============================================================
  include ActiveModel::Model
  
  # == Constants ==============================================================
  BARGAIN_FINDER_MAX_RQ_WSDL          = "http://files.developer.sabre.com/wsdl/sabreXML1.0.00/shopping/BargainFinderMaxRQ_v1-9-2.wsdl"
  HEADER_ACTION_BARGAIN_FINDER_MAX_RQ = "BargainFinderMaxRQ"
  TRIP_TYPE_ONE_WAY                   = "OneWay"
  TRIP_TYPE_RETURN                    = "Return"
  TRIP_TYPE_CIRCLE                    = "Circle"
  
  # == Instance methods =======================================================
  def build_origin_and_destination(departure_date_time, origin_location, destination_location)
    return { departure_date_time: departure_date_time, origin_location: origin_location, destination_location: destination_location }
  end  
  
  def build_passenger_type_and_quantity(passenger_type, quantity)
    return { passenger_type: passenger_type, quantity: quantity }
  end
  
  def operation_attributes
    attributes = {
      "Target"          => "Production",
      "Version"         => "1.9.2",
      "ResponseType"    => "OTA",
      "ResponseVersion" => "1.9.2",
    }
    
    return attributes
  end  
  
  def namespaces
    namespaces = {
      "xmlns:env" => "http://schemas.xmlsoap.org/soap/envelope/", 
      "xmlns:ns"  => "http://www.opentravel.org/OTA/2003/05",
      "xmlns:mes" => "http://www.ebxml.org/namespaces/messageHeader", 
      "xmlns:sec" => "http://schemas.xmlsoap.org/ws/2002/12/secext"
    }
    
    return namespaces
  end  
  
  def build_pos_section
    section = {
      "ns:Source" => {
        :@PseudoCityCode => "6A3H",
        
        "ns:RequestorID" => {
          :@Type => "1",
          :@ID   => "1",

          "ns:CompanyName" => {
            :@Code => "TN",  
          },
        },
      },
    }
    
    return section
  end
  
  def build_origin_destination_information_section(origins_and_destinations)
    raise "'origins_and_destinations' parameters should not be empty." if origins_and_destinations.empty?
    
    origin_destination_list = []
    
    count = 0
    origins_and_destinations.each do |entry|
      count += 1
      origin_destination_list << {
        :@RPH => count,
        "ns:DepartureDateTime"   => { :content!      => entry[:departure_date_time ], },
        "ns:OriginLocation"      => { :@LocationCode => entry[:origin_location     ], },
        "ns:DestinationLocation" => { :@LocationCode => entry[:destination_location], },
      }
    end
    
    return origin_destination_list
  end  
  
  def build_travel_preferences_section(trip_type)
    section = {
      "ns:TPA_Extensions" => {
        "ns:TripType" => {
          :@Value => trip_type,
        },
      },
    }
    
    return section
  end
  
  def build_passenger_type_quantity_section(passenger_types_and_quantities)
    raise "'passenger_types_and_quantities' parameters should not be empty." if passenger_types_and_quantities.empty?
    
    passenger_type_quantity_list = []
    
    seats_requested = 0
    passenger_types_and_quantities.each do |entry|
      passenger_type_quantity_list << {
        :@Code     => entry[:passenger_type],
        :@Quantity => entry[:quantity      ],
      }
      seats_requested += entry[:quantity]
    end
    
    return seats_requested, passenger_type_quantity_list
  end  
  
  def build_message_body(origins_and_destinations, trip_type, passenger_types_and_quantities, request_type)
  
    pos_section                                   = build_pos_section
    origin_destination_information_section        = build_origin_destination_information_section(origins_and_destinations)
    travel_preferences_section                    = build_travel_preferences_section(TRIP_TYPE_ONE_WAY)
    seats_requested, passenger_type_quantity_list = build_passenger_type_quantity_section(passenger_types_and_quantities)

    message_body = {
      "ns:POS"                          => pos_section,
      "ns:OriginDestinationInformation" => origin_destination_information_section, 
      "ns:TravelPreferences"            => travel_preferences_section,
      "ns:TravelerInfoSummary" => {
        "ns:SeatsRequested"    => seats_requested,
        "ns:AirTravelerAvail"  => {
          "ns:PassengerTypeQuantity" => passenger_type_quantity_list,
        },
      },
      "ns:TPA_Extensions" => {
        "ns:IntelliSellTransaction" => {
          "ns:RequestType" => {
            :@Name => request_type,
          },
        },
      },
    } 
    
    return message_body 
  end  
  
  def air_availability_one_way(session, origins_and_destinations, passenger_types_and_quantities, request_type="50ITINS")

    savon_client = Savon.client(
      wsdl:                    BARGAIN_FINDER_MAX_RQ_WSDL, 
      namespaces:              namespaces,
      soap_header:             session.build_header(HEADER_ACTION_BARGAIN_FINDER_MAX_RQ, session.binary_security_token),
      log:                     true, 
      log_level:               :debug, 
      pretty_print_xml:        true,
      convert_request_keys_to: :none,
      namespace_identifier:    :ns
    )

    message_body = build_message_body(origins_and_destinations, TRIP_TYPE_ONE_WAY, passenger_types_and_quantities, request_type)  
    response     = savon_client.call(:bargain_finder_max_rq,  soap_action: "ns:OTA_AirLowFareSearchRQ", attributes: operation_attributes, message: message_body)
    
    return savon_client
  end

  def air_availability_return(session, origins_and_destinations, passenger_types_and_quantities, request_type="50ITINS")

    savon_client = Savon.client(
      wsdl:                    BARGAIN_FINDER_MAX_RQ_WSDL, 
      namespaces:              namespaces,
      soap_header:             session.build_header(HEADER_ACTION_BARGAIN_FINDER_MAX_RQ, session.binary_security_token),
      log:                     true, 
      log_level:               :debug, 
      pretty_print_xml:        true,
      convert_request_keys_to: :none,
      namespace_identifier:    :ns
    )

    message_body = build_message_body(origins_and_destinations, TRIP_TYPE_RETURN, passenger_types_and_quantities, request_type)  
    response     = savon_client.call(:bargain_finder_max_rq,  soap_action: "ns:OTA_AirLowFareSearchRQ", attributes: operation_attributes, message: message_body)
    
    return savon_client
  end

  def air_availability_circle(session, origins_and_destinations, passenger_types_and_quantities, request_type="50ITINS")

    savon_client = Savon.client(
      wsdl:                    BARGAIN_FINDER_MAX_RQ_WSDL, 
      namespaces:              namespaces,
      soap_header:             session.build_header(HEADER_ACTION_BARGAIN_FINDER_MAX_RQ, session.binary_security_token),
      log:                     true, 
      log_level:               :debug, 
      pretty_print_xml:        true,
      convert_request_keys_to: :none,
      namespace_identifier:    :ns
    )

    message_body = build_message_body(origins_and_destinations, TRIP_TYPE_CIRCLE, passenger_types_and_quantities, request_type)  
    response     = savon_client.call(:bargain_finder_max_rq,  soap_action: "ns:OTA_AirLowFareSearchRQ", attributes: operation_attributes, message: message_body)
    
    return savon_client
  end
  
end
