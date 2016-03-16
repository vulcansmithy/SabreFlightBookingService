class PassengerDetail
  
  # == Includes ===============================================================
  include ActiveModel::Model
  
  # == Constants ==============================================================
  PASSENGER_DETAILS_RQ_WSDL           = "http://files.developer.sabre.com/wsdl/sabreXML1.0.00/ServicesPlatform/PassengerDetails3.2.0RQ.wsdl"
  NON_PRODUCTION_ENVIRONMENT_ENDPOINT = "https://sws3-crt.cert.sabre.com"
  
  PASSENGER_DETAILS_RQ                = "PassengerDetailsRQ"
  
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
      wsdl:                    PASSENGER_DETAILS_RQ_WSDL, 
      namespaces:              namespaces,
      soap_header:             session.build_header(PASSENGER_DETAILS_RQ, session.binary_security_token),
      log:                     true, 
      log_level:               :debug, 
      pretty_print_xml:        true,
      convert_request_keys_to: :none,
      namespace_identifier:    :v,
    )
    
    @savon_client.globals.endpoint(NON_PRODUCTION_ENVIRONMENT_ENDPOINT)  if session.non_production_environment

    return @savon_client
  end

end
