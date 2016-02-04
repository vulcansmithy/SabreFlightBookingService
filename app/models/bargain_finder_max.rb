class BargainFinderMax
  
  # == Includes ===============================================================
  include ActiveModel::Model
  
  # == Constants ==============================================================
  BARGAIN_FINDER_MAX_RQ_WSDL          = "http://files.developer.sabre.com/wsdl/sabreXML1.0.00/shopping/BargainFinderMaxRQ_v1-9-2.wsdl"
  HEADER_ACTION_BARGAIN_FINDER_MAX_RQ = "BargainFinderMaxRQ"
  TRIP_TYPE_ONE_WAY                   = "OneWay"
  
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
  
  def bfm_one_way(session, origin_destination_information)
    
    namespaces = {
      "xmlns:env" => "http://schemas.xmlsoap.org/soap/envelope/", 
      "xmlns:ns"  => "http://www.opentravel.org/OTA/2003/05",
      "xmlns:mes" => "http://www.ebxml.org/namespaces/messageHeader", 
      "xmlns:sec" => "http://schemas.xmlsoap.org/ws/2002/12/secext"
    }

    message_body = {
      "ns:POS" => build_pos_section,
      "ns:OriginDestinationInformation" => {
        :@RPH => "1",
        
        # DepartureDateTime
        "ns:DepartureDateTime" => "2016-02-14T00:00:00",
        
        # OriginLocation
        "ns:OriginLocation" => {
          :@LocationCode => "MNL",
        },

        # DestinationLocation
        "ns:DestinationLocation" => {
          :@LocationCode => "SIN",     
        },
      },
      "ns:TravelPreferences" => {
        "ns:TPA_Extensions" => {
          "ns:TripType" => {
            :@Value => TRIP_TYPE_ONE_WAY,
          },
        },
      },
      "ns:TravelerInfoSummary" => {
        "ns:SeatsRequested"    => 3,
        "ns:AirTravelerAvail"  => {
          "ns:PassengerTypeQuantity" => [
            {
              :@Code     => "ADT",
              :@Quantity => "1",  
            },
            {
              :@Code     => "CNN",
              :@Quantity => "1",  
            },
            {
              :@Code     => "INF",
              :@Quantity => "1",  
            },
          ],
        },
      },
      "ns:TPA_Extensions" => {
        "ns:IntelliSellTransaction" => {
          "ns:RequestType" => {
            :@Name => "50ITINS",
          },
        },
      },
    }
    
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
    
    response = savon_client.call(:bargain_finder_max_rq,  soap_action: "ns:OTA_AirLowFareSearchRQ", attributes: operation_attributes, message: message_body)
    
    return savon_client
  end
  
end
