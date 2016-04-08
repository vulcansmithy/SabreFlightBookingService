class EnhancedAirBook 
  
  # == Includes ===============================================================
  include ActiveModel::Model
  
  # == Constants ==============================================================
  ENHANCED_AIR_BOOK_RQ_WSDL = "http://files.developer.sabre.com/wsdl/sabreXML1.0.00/ServicesPlatform/EnhancedAirBook3.2.0RQ.wsdl"
  ENHANCED_AIR_BOOK_RQ      = "EnhancedAirBookRQ"
  
  # == Class Methods ==========================================================
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
  
  def execute_enhanced_air_book 
    
    flight_segment_origin_destination_information = EnhancedAirBook.build_flight_segment_origin_destination_information(
      :@DepartureDateTime               => "2016-06-05T17:05:00",
      :@FlightNumber                    => "764",
      :@NumberInParty                   => "1",
      :@ResBookDesigCode                => "H",
      :@Status                          => "NN",
      :@LocationCodeDestinationLocation => "SIN",
      :@CodeMarketingAirline            => "3K",
      :@LocationCodeOriginLocation      => "MNL",
    )

    begin
      @message_body = {
        "v:OTA_AirBookRQ" => {
          "v:OriginDestinationInformation" => {
            "v:FlightSegment" => [],
          },
        },
      
        "v:PostProcessing" => {
          :@IgnoreAfter => "true",
          "v:RedisplayReservation" => { },
        },
        "v:PreProcessing" => {
          "v:UniqueID" => { :@ID => "" },
        },
      }
      
      
      @message_body["v:OTA_AirBookRQ"]["v:OriginDestinationInformation"]["v:FlightSegment"] << {
        :@DepartureDateTime     => flight_segment_origin_destination_information[:@DepartureDateTime ],
        :@FlightNumber          => flight_segment_origin_destination_information[:@FlightNumber      ],
        :@NumberInParty         => flight_segment_origin_destination_information[:@NumberInParty     ],
        :@ResBookDesigCode      => flight_segment_origin_destination_information[:@ResBookDesigCode  ],
        :@Status                => flight_segment_origin_destination_information[:@Status            ],
        "v:DestinationLocation" => flight_segment_origin_destination_information[:DestinationLocation],
        "v:MarketingAirline"    => flight_segment_origin_destination_information[:MarketingAirline   ], 
        "v:OriginLocation"      => flight_segment_origin_destination_information[:OriginLocation     ],
      }
      @message_body["v:OTA_AirBookRQ"]["v:OriginDestinationInformation"]["v:FlightSegment"] << {
        :@DepartureDateTime     => flight_segment_origin_destination_information[:@DepartureDateTime ],
        :@FlightNumber          => flight_segment_origin_destination_information[:@FlightNumber      ],
        :@NumberInParty         => flight_segment_origin_destination_information[:@NumberInParty     ],
        :@ResBookDesigCode      => flight_segment_origin_destination_information[:@ResBookDesigCode  ],
        :@Status                => flight_segment_origin_destination_information[:@Status            ],
        "v:DestinationLocation" => flight_segment_origin_destination_information[:DestinationLocation],
        "v:MarketingAirline"    => flight_segment_origin_destination_information[:MarketingAirline   ], 
        "v:OriginLocation"      => flight_segment_origin_destination_information[:OriginLocation     ],
      }
      
      
      puts "@DEBUG #{__LINE__}    @message_body=#{ap @message_body}"
    
      call_response = @savon_client.call(
        :enhanced_air_book_rq, 
        soap_action: "v:EnhancedAirBookRQ", 
        attributes:  operation_attributes, 
        message:     @message_body
      )
      
    rescue Savon::SOAPFault => error
      puts "@DEBUG #{__LINE__}    #{ap error.to_hash[:fault]}"
      
      return { status: :failed,  result: error.to_hash[:fault] }
    else
      
      return { status: :success, result: call_response.body[:enhanced_air_book_rs] }
    end
  end

end