class PassengerDetail
  
  # == Includes ===============================================================
  include ActiveModel::Model
  
  # == Constants ==============================================================
  PASSENGER_DETAILS_RQ_WSDL = "http://files.developer.sabre.com/wsdl/sabreXML1.0.00/ServicesPlatform/PassengerDetails3.2.0RQ.wsdl"
  PASSENGER_DETAILS_RQ      = "PassengerDetailsRQ"
  
  # == Instance methods =======================================================
  def initialize
    @savon_client = nil
  end 
  
  def namespaces
    namespaces = {
      "xmlns:env" => "http://schemas.xmlsoap.org/soap/envelope/", 
      "xmlns:v"   => "http://services.sabre.com/sp/pd/v3_2", 
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
    
    @savon_client = session.set_endpoint_environment(@savon_client)

    return @savon_client
  end
  
  def operation_attributes
    attributes = {
      "xmlns"         => "http://services.sabre.com/sp/pd/v3_2",
      "version"       => "3.2.0",
      "IgnoreOnError" => "false",
      "HaltOnError"   => "false",
    }
    
    return attributes
  end
  
  def execute_passenger_detail

    message_body = {
      "v:PostProcessing" => {
        :@IgnoreAfter          => "false",
        :@RedisplayReservation => "true",
        :@UnmaskCreditCard     => "true",
      },
  
      "v:PreProcessing" => {
        :@IgnoreBefore => "true",
        "v:UniqueID" => { :@ID => "" },
      },

      "v:SpecialReqDetails" => {
        "v:SpecialServiceRQ" => {
          "v:SpecialServiceInfo" => {
            "v:AdvancePassenger" => {
              :@SegmentNumber => "A",
              "v:Document"    => {
                :@ExpirationDate => "2018-05-26",
                :@Number         => "1234567890",
                :@Type           => "P",
                
                "v:IssueCountry"       => "FR",
                "v:NationalityCountry" => "FR",
              },
              "v:PersonName"  => {
                :@DateOfBirth    => "1980-12-02",
                :@Gender         => "M",
                :@NameNumber     => "1.1",
                :@DocumentHolder => "true",
                "v:GivenName"  => "JAMES",
                "v:MiddleName" => "MALCOLM",
                "v:Surname"    => "GREEN",
              },
              "v:VendorPrefs" => {
                "v:Airline"   => { :@Hosted => "false",  },
              },
            },
          },
        },
      },
      
      "v:TravelItineraryAddInfoRQ" => {
        "v:AgencyInfo"   => {
          "v:Address"  => {
            "v:AddressLine"     => "SABRE TRAVEL",
            "v:CityName"        => "SOUTHLAKE",
            "v:CountryCode"     => "US",
            "v:PostalCode"      => "76092",     
            "v:StateCountyProv" => { :@StateCode => "TX", },
            "v:StreetNmbr"      => "3150 SABRE DRIVE", 
            "v:VendorPrefs"     => {
              "v:Airline"       => { :@Hosted => "true", },
            },
          },
        },
        "v:CustomerInfo" => {
          "v:ContactNumbers" => {
            "v:ContactNumber" => {
              :@NameNumber   => "1.1",
              :@Phone        => "817-555-1212",
              :@PhoneUseType => "H", 
            }, 
          },
          "v:PersonName"    =>  {
            :@NameNumber    => "1.1",   
            :@NameReference => "ABC123",  
            :@PassengerType => "ADT", 
            
            "v:GivenName"   => "MARCIN",
            "v:Surname"     => "LACHOWICZ",
          },
        },
      },
    }
    
   response = @savon_client.call(:passenger_details_rq, soap_action: "v:PassengerDetailsRQ", attributes: operation_attributes, message: message_body)
  end

end
