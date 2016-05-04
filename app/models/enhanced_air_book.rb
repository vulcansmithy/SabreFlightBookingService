class EnhancedAirBook 
  
  # == Includes ===============================================================
  include ActiveModel::Model
  
  # == Constants ==============================================================
  ENHANCED_AIR_BOOK_RQ_WSDL = "http://files.developer.sabre.com/wsdl/sabreXML1.0.00/ServicesPlatform/EnhancedAirBook3.2.0RQ.wsdl"
  ENHANCED_AIR_BOOK_RQ      = "EnhancedAirBookRQ"
  
  # == Class Methods ==========================================================
  # Build the FlightSection section.
  # 
  # @param [Hash] args The args hash.
  # @option args [String] :@DepartureDateTime "DepartureDateTime" is used to specify the time and date of flight departure.  
  # @option args [String] :@FlightNumber "FlightNumber" is used to specify the flight number.  OPEN can also be passed if the user desires an open space ticket.  
  # @option args [String] :@NumberInParty "NumberInParty" is used to specify the number of passengers that need to be booked during this transaction.
  # @option args [String] :@ResBookDesigCode "ResBookDesigCode" is used to specify the booking class.
  # @option args [String] :@Status "Status" is used to specify the action code to be used to sell the flight inventory.
  # @option args [String] :@LocationCodeDestinationLocation "LocationCodeDestinationLocation" is used to specify the arrival airport code.
  # @option args [String] :@CodeMarketingAirline "CodeMarketingAirline" is used to specify the marketing airline code.
  # @option args [String] :@LocationCodeOriginLocation "LocationCodeOriginLocation" is used to specify the departure airport code.
  # @return args [Hash] Return a hash representing the FlightSection section.
  def self.build_flight_segment_origin_destination_information(args)
    defaults = {}
    args.merge!(defaults)
    
    flight_segment_section = Hash.new
    
    unless args[:@DepartureDateTime].nil?
      flight_segment_section[:@DepartureDateTime] = args[:@DepartureDateTime]         
    end 
    
    unless args[:@FlightNumber].nil?
      flight_segment_section[:@FlightNumber] = args[:@FlightNumber]         
    end     
    
    unless args[:@NumberInParty].nil?
      flight_segment_section[:@NumberInParty] = args[:@NumberInParty]         
    end   
    
    unless args[:@ResBookDesigCode].nil?
      flight_segment_section[:@ResBookDesigCode] = args[:@ResBookDesigCode]         
    end  
    
    unless args[:@Status].nil?
      flight_segment_section[:@Status] = args[:@Status]         
    end  

    unless args[:@LocationCodeDestinationLocation].nil?
      flight_segment_section[:DestinationLocation] = { :@LocationCode => args[:@LocationCodeDestinationLocation] }
    end  

    if args[:@CodeMarketingAirline].nil? == false || args[:@FlightNumber].nil? == false
      flight_segment_section[:MarketingAirline] = { :@Code => args[:@CodeMarketingAirline], :@FlightNumber => args[:@FlightNumber] }
    end  
    
    unless args[:@LocationCodeOriginLocation].nil?
      flight_segment_section[:OriginLocation] = { :@LocationCode => args[:@LocationCodeOriginLocation] }
    end  
    
    return flight_segment_section
  end
  
  # Build individual FlightSegment section. There could be 1 or more FlightSegment. This method is a helper method that builds those individual entry.
  # 
  # @param [flight_segment_origin_destination_information] "flight_segment_origin_destination_information" is a hash previously build using the build_flight_segment_origin_destination_information method.
  # @return args [Hash] Return a hash representing the FlightSegment section.
  def self.build_individual_flight_segment(flight_segment_origin_destination_information)
    flight_segment_section = Hash.new
    
    flight_segment_section = {
      :@DepartureDateTime     => flight_segment_origin_destination_information[:@DepartureDateTime ],
      :@FlightNumber          => flight_segment_origin_destination_information[:@FlightNumber      ],
      :@NumberInParty         => flight_segment_origin_destination_information[:@NumberInParty     ],
      :@ResBookDesigCode      => flight_segment_origin_destination_information[:@ResBookDesigCode  ],
      :@Status                => flight_segment_origin_destination_information[:@Status            ],
      "v:DestinationLocation" => flight_segment_origin_destination_information[:DestinationLocation],
      "v:MarketingAirline"    => flight_segment_origin_destination_information[:MarketingAirline   ], 
      "v:OriginLocation"      => flight_segment_origin_destination_information[:OriginLocation     ],
    }
  
    return flight_segment_section
  end
  
  # == Instance methods =======================================================
  def initialize
    @savon_client = nil
    @message_body = {}
  end 
  
  def namespaces
    namespaces = {
      "xmlns:env" => "http://schemas.xmlsoap.org/soap/envelope/", 
      "xmlns:v"   => "http://services.sabre.com/sp/eab/v3_2", 
      "xmlns:mes" => "http://www.ebxml.org/namespaces/messageHeader", 
      "xmlns:sec" => "http://schemas.xmlsoap.org/ws/2002/12/secext",
    }
    
    return namespaces
  end
  
  def available_operations
    raise "No established 'savon_client' instance." if @savon_client.nil?
    
    return @savon_client.operations
  end
  
  def establish_connection(session)
    raise "Passed 'session' parameter was nil. Said parameter must not be nil." if session.nil?
    
    @savon_client = Savon.client(
      wsdl:                    ENHANCED_AIR_BOOK_RQ_WSDL, 
      namespaces:              namespaces,
      soap_header:             session.build_header(ENHANCED_AIR_BOOK_RQ, session.binary_security_token),
      log:                     true, 
      log_level:               :debug, 
      pretty_print_xml:        true,
      convert_request_keys_to: :none,
      namespace_identifier:    :v,
    )
    
    @savon_client = session.set_endpoint_environment(@savon_client)

    return @savon_client
  end
  
  def operation_attributes
    attributes = {
      "version"       => "3.2.0",
      "xmlns"         => "http://services.sabre.com/sp/eab/v3_2",
      "IgnoreOnError" => "true",
      "HaltOnError"   => "true",
    }
    
    return attributes
  end
  
  def execute_request(args)
    defaults = {}
    args.merge!(defaults)
    
    raise "Missing :flight_segments." if args[:flight_segments].nil?
    
    raise "Empty :flight_segments."   if args[:flight_segments].empty?
    
    flight_segments = args[:flight_segments] 

    begin
      @message_body = {
        "v:OTA_AirBookRQ" => {
          "v:OriginDestinationInformation" => {
            "v:FlightSegment" => [],
          },
        },
      
        "v:PostProcessing" => {
          :@IgnoreAfter => "false",
          "v:RedisplayReservation" => { },
        },
        "v:PreProcessing" => {
          "v:UniqueID" => { :@ID => "" },
        },
      }
      
      flight_segments.each do |flight_segment|
        @message_body["v:OTA_AirBookRQ"]["v:OriginDestinationInformation"]["v:FlightSegment"] << EnhancedAirBook.build_individual_flight_segment(flight_segment)  
      end
    
      call_response = @savon_client.call(
        :enhanced_air_book_rq, 
        soap_action: "v:EnhancedAirBookRQ", 
        attributes:  operation_attributes, 
        message:     @message_body
      )
      
    rescue Savon::SOAPFault => error
      puts "@DEBUG #{__LINE__}    #{ap error.to_hash[:fault]}"
      
      return { status: :failed,  error: error.to_hash[:fault] }
    else
      returned_data = call_response.body[:enhanced_air_book_rs]

      return { status: :success, data:  returned_data }
    end
  end

end
