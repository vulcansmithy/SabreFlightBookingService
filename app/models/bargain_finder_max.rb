class BargainFinderMax
  
  # == Includes ===============================================================
  include ActiveModel::Model
  
  # == Constants ==============================================================
  BARGAIN_FINDER_MAX_RQ_WSDL          = "http://files.developer.sabre.com/wsdl/sabreXML1.0.00/shopping/BargainFinderMaxRQ_v1-9-2.wsdl"
  HEADER_ACTION_BARGAIN_FINDER_MAX_RQ = "BargainFinderMaxRQ"
  
  # == Instance methods =======================================================
  def operation_attributes
    attributes = {
      "Target"          => "Production",
      "Version"         => "1.9.2",
      "ResponseType"    => "OTA",
      "ResponseVersion" => "1.9.2",
    }
    
    return attributes
  end  
  
  def build_pos_section
    section = {
      "xsd1:Source" => {
        "xsd1:RequestorID" => {
          "xsd1:CompanyName" => "",
          :attributes! => {
            "xsd1:CompanyName" => {
              "Code" => "TN",    
            },    
          },
        },
        :attributes! => {
          "xsd1:RequestorID" => {
            "Type" => "1",
            "ID"   => "1",
          },
        },
      },
      :attributes! => {
        "xsd1:Source" => {
          "PseudoCityCode" => "6A3H",    
        },    
      },
    }
    
    return section
  end
  
  def bfm_one_way(session, origin_destination_information)
    
    namespaces = {
      "xmlns:env" => "http://schemas.xmlsoap.org/soap/envelope/", 
      "xmlns:ns"  => "http://www.opentravel.org/OTA/2002/11",
      "xmlns:mes" => "http://www.ebxml.org/namespaces/messageHeader", 
      "xmlns:sec" => "http://schemas.xmlsoap.org/ws/2002/12/secext"
    }

    message_body = {
      "xsd1:POS" => build_pos_section,
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
    
   response = savon_client.call(:bargain_finder_max_rq, attributes: operation_attributes, message: message_body)
    
    return savon_client
  end
  
end
