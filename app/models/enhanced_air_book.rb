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
      "xmlns:ns"  => "http://webservices.sabre.com/sabreXML/2011/10", 
      "xmlns:mes" => "http://www.ebxml.org/namespaces/messageHeader", 
      "xmlns:sec" => "http://schemas.xmlsoap.org/ws/2002/12/secext"
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
      namespace_identifier:    :ns
    )
    
    @savon_client.globals.endpoint(NON_PRODUCTION_ENVIRONMENT_ENDPOINT)  if session.non_production_environment

    return @savon_client
  end
  
  def operation_attributes
    attributes = {
      "ReturnHostCommand" => "false",
      "TimeStamp"         => Time.now.strftime("%Y-%m-%dT%H:%M:%SZ"),
      "Version"           => "2.3.0",
      "xmlns"             => "http://webservices.sabre.com/sabreXML/2011/10",
      "xmlns:xs"          => "http://www.w3.org/2001/XMLSchema",
      "xmlns:xsi"         => "http://www.w3.org/2001/XMLSchema-instance",
    }
    
    return attributes
  end
  
=begin  
  def execute 
    
    message_body = {
      "ns:OriginDestinationInformation" => {
        "ns:FlightSegment" => {
          :@DepartureDateTime => departure_date_time,
          "ns:DestinationLocation" => { :@LocationCode => origin_location,      },
          "ns:OriginLocation"      => { :@LocationCode => destination_location, },
        },
      },
    }
    
    response = @savon_client.call(:ota_air_avail_rq, soap_action: "ns:OTA_AirAvailRQ", attributes: operation_attributes, message: message_body)
  end
=end  

end
