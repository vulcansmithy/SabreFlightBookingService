class PassengerDetail
  
  # == Includes ===============================================================
  include ActiveModel::Model
  
  # == Constants ==============================================================
  PASSENGER_DETAILS_RQ_WSDL = "http://files.developer.sabre.com/wsdl/sabreXML1.0.00/ServicesPlatform/PassengerDetails3.2.0RQ.wsdl"
  PASSENGER_DETAILS_RQ      = "PassengerDetailsRQ"
  
  # == Class Methods ==========================================================
  # Build the Visa section under the AdvancePassenger.Document section.
  # 
  # @param [Hash] args The args hash.
  # @option args [String] :issue_date The visa issue date.
  # @option args [String] ::applicable_country The applicable country.
  # @option args [String] :place_of_birth The place of birth.
  # @option args [String] :place_of_issue The place of issue.
  # @return args [Hash] Return a hash representing the Visa section.
  def self.build_advance_passenger_document_visa_section(args)
    defaults = {}
    args.merge!(defaults)
    
    visa_section = Hash.new
    
    unless args[:issue_date].nil?
      visa_section[:@IssueDate] = args[:issue_date]         
    end  
      
    unless args[:applicable_country].nil?
      visa_section[:ApplicableCountry] = args[:applicable_country] 
    end  
    
    unless args[:place_of_birth].nil?
      visa_section[:PlaceOfBirth] = args[:place_of_birth]     
    end
      
    unless args[:place_of_issue].nil?
      visa_section[:PlaceOfIssue] = args[:place_of_issue]    
    end
      
    return visa_section
  end
  
  # == Instance methods =======================================================
  def initialize
    @savon_client = nil
    @message_body = {}
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
    @message_body = {
      "v:PostProcessing" => {
        :@IgnoreAfter          => "false",
        :@RedisplayReservation => "true",
      },
  
      "v:PreProcessing" => {
        :@IgnoreBefore => "false",
        "v:UniqueID"   => { :@ID => "" },
      },

      "v:SpecialReqDetails" => {
        "v:SpecialServiceRQ" => {
          "v:SpecialServiceInfo" => {
            "v:AdvancePassenger" => {
              :@SegmentNumber => "A",
              
              "v:Document" => {
                :@ExpirationDate       => "2018-05-26",
                :@Number               => "1234567890",
                :@Type                 => "P",
                
                "v:IssueCountry"       => "FR",
                "v:NationalityCountry" => "FR",
              },
              
              "v:PersonName" => {
                :@DateOfBirth    => "1980-12-02",
                :@Gender         => "M",
                :@NameNumber     => "1.1",
                :@DocumentHolder => "true",
                
                "v:GivenName"    => "JAMES",
                "v:MiddleName"   => "MALCOLM",
                "v:Surname"      => "GREEN",
              },
              
              "v:VendorPrefs" => { "v:Airline" => { :@Hosted => "false" } },
            },
          },
        },
      },
      
      "v:TravelItineraryAddInfoRQ" => {
        "v:AgencyInfo" => {
          "v:Address"  => {
            "v:AddressLine"     => "SABRE TRAVEL",
            "v:CityName"        => "SOUTHLAKE",
            "v:CountryCode"     => "US",
            "v:PostalCode"      => "76092",     
            "v:StateCountyProv" => { :@StateCode => "TX" },
            "v:StreetNmbr"      => "3150 SABRE DRIVE", 
            "v:VendorPrefs"     => { "v:Airline" => { :@Hosted => "true" } },
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
          "v:PersonName"     => {
            :@NameNumber    => "1.1",   
            :@NameReference => "ABC123",  
            :@PassengerType => "ADT", 
            
            "v:GivenName"   => "JAMES",
            "v:Surname"     => "GREEN",
          },
        },
      },
    }
    
    call_response  = @savon_client.call(:passenger_details_rq, soap_action: "v:PassengerDetailsRQ", attributes: operation_attributes, message: @message_body)
    target_element = (call_response.body[:passenger_details_rs])[:travel_itinerary_read_rs]

    return target_element.nil? ? {} : target_element
  end

end
