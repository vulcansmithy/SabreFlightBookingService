class BargainFinderMax
  
  BARGAIN_FINDER_MAX_RQ_WSDL          = "http://files.developer.sabre.com/wsdl/sabreXML1.0.00/shopping/BargainFinderMaxRQ_v1-9-2.wsdl"
  
  HEADER_ACTION_BARGAIN_FINDER_MAX_RQ = "BargainFinderMaxRQ"
  
  include ActiveModel::Model
  
  def initialize(attributes={})
    super
  end  
  
  def bfm_one_way(session)
    
    namespaces = {
      "xmlns:env" => "http://schemas.xmlsoap.org/soap/envelope/", 
      "xmlns:ns"  => "http://www.opentravel.org/OTA/2002/11",
      "xmlns:mes" => "http://www.ebxml.org/namespaces/messageHeader", 
      "xmlns:sec" => "http://schemas.xmlsoap.org/ws/2002/12/secext"
    }
    
    savon_client = Savon.client(
      wsdl:                    BARGAIN_FINDER_MAX_RQ_WSDL, 
      namespaces:              namespaces,
      soap_header:             session.build_header(HEADER_ACTION_BARGAIN_FINDER_MAX_RQ, session.binary_security_token),
      log:                     true, 
      log_level:               :debug, 
      pretty_print_xml:        true,
      convert_request_keys_to: :none
    )
    
    return savon_client
  end
  
end
