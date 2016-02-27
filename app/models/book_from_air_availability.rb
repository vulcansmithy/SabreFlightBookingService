class BookFromAirAvailability
  
  # == Includes ===============================================================
  include ActiveModel::Model
  
  # == Constants ==============================================================
  SHORT_SELL_LLS_RQ_WSDL              = "http://webservices.sabre.com/wsdl/tpfc/ShortSellLLS2.0.1RQ.wsdl"
  NON_PRODUCTION_ENVIRONMENT_ENDPOINT = "https://sws3-crt.cert.sabre.com"
  
  HEADER_ACTION_SHORT_SELL_LLS_RQ     = "ShortSellLLSRQ"

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
      wsdl:                    SHORT_SELL_LLS_RQ_WSDL, 
      namespaces:              namespaces,
      soap_header:             session.build_header(HEADER_ACTION_SHORT_SELL_LLS_RQ, session.binary_security_token),
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
      "ReturnHostCommand" => "true",
      "TimeStamp"         => Time.now.strftime("%Y-%m-%dT%H:%M:%SZ"),
      "Version"           => "2.0.1",
      "xmlns"             => "http://webservices.sabre.com/sabreXML/2011/10",
      "xmlns:xs"          => "http://www.w3.org/2001/XMLSchema",
      "xmlns:xsi"         => "http://www.w3.org/2001/XMLSchema-instance",
    }
    
    return attributes
  end
  
  def execute_booking
    message_body = {
      "ns:OriginDestinationInformation" => {
        "ns:FlightSegment" => {
          :@DepartureDateTime      => "06-05",
          :@FlightNumber           => "764",
          :@NumberInParty          => "3",
          :@ResBookDesigCode       => "Y",
          :@Status                 => "NN",
          "ns:DestinationLocation" => { :@LocationCode => "SIN" },
          "ns:MarketingAirline"    => { :@Code => "3K", :@FlightNumber => "764" },
          "ns:OriginLocation"      => { :@LocationCode => "MNL" }, 
        },  
      },
    }
    
    response = @savon_client.call(:short_sell_rq, soap_action: "ns:ShortSellRQ", attributes: operation_attributes, message: message_body)
  end  

end
