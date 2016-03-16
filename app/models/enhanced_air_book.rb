class EnhancedAirBook 
  
  # == Includes ===============================================================
  include ActiveModel::Model
  
  # == Constants ==============================================================
  ENHANCED_AIR_BOOK_RQ_WSDL           = "http://files.developer.sabre.com/wsdl/sabreXML1.0.00/ServicesPlatform/EnhancedAirBook3.2.0RQ.wsdl"
  NON_PRODUCTION_ENVIRONMENT_ENDPOINT = "https://sws3-crt.cert.sabre.com"
  
  ENHANCED_AIR_BOOK_RQ                = "EnhancedAirBookRQ"
  
  # == Instance methods =======================================================
  def initialize
    @savon_client = nil
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
    
    @savon_client.globals.endpoint(NON_PRODUCTION_ENVIRONMENT_ENDPOINT)  if session.non_production_environment

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
    message_body = {
      "v:OTA_AirBookRQ" => {
        "v:OriginDestinationInformation" => {
          "v:FlightSegment" => {
            :@DepartureDateTime => "2016-06-05T17:05:00",
            :@FlightNumber      => "764",
            :@NumberInParty     => "1",
            :@ResBookDesigCode  => "H",
            :@Status            => "NN",
            
            "v:DestinationLocation" => { :@LocationCode => "SIN" },
            "v:MarketingAirline"    => { :@Code         => "3K", :@FlightNumber => "764" },
            "v:OriginLocation"      => { :@LocationCode => "MNL" },
          },
          
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
    
   response = @savon_client.call(:enhanced_air_book_rq, soap_action: "v:EnhancedAirBookRQ", attributes: operation_attributes, message: message_body)
  end

end
