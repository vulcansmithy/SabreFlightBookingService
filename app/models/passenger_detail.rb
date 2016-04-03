class PassengerDetail
  
  # == Includes ===============================================================
  include ActiveModel::Model
  
  # == Constants ==============================================================
  PASSENGER_DETAILS_RQ_WSDL = "http://files.developer.sabre.com/wsdl/sabreXML1.0.00/ServicesPlatform/PassengerDetails3.2.0RQ.wsdl"
  PASSENGER_DETAILS_RQ      = "PassengerDetailsRQ"
  
  # == Class Methods ==========================================================
  # Build the Document section. Document section is under the AdvancePassenger section.
  # 
  # @param [Hash] args The args hash.
  # @option args [String] :@ExpirationDate "ExpirationDate" is used to specify the document expiration date. ExpirationDate" follows this format: YYYY-MM-DD.
  # @option args [String] :@Number "Number" is used to specify the document number.
  # @option args [String] :@Type "Type" is used to specify the document type. Type" is used to specify the document type. Acceptable values include: "A" - Alien resident card, "C" - Permanent resident card, "F" - Facilitation document, "I" - National ID card, "IN" - Nexus Card.  "M" - Military, "N" - Naturalization certificate, "P" - Passport, "T" - Refugee travel document and re-entry permit, US Travel document, "V" - Border crossing card.
  # @option args [String] :IssueCountry The issuing country.
  # @option args [String] :NationalityCountry The person's nationality country.
  # @return args [Hash] Return a hash representing the Document section.
  def self.build_advance_passenger_document_section(args)
    defaults = {}
    args.merge!(defaults)
    
    document_section = Hash.new
    
    unless args[:@ExpirationDate].nil?
      document_section[:@ExpirationDate] = args[:@ExpirationDate]         
    end  

    unless args[:@Number].nil?
      document_section[:@Number] = args[:@Number]         
    end    
    
    unless args[:@Type].nil?
      document_section[:@Type] = args[:@Type]         
    end   
    
    unless args[:IssueCountry].nil?
      document_section[:IssueCountry] = args[:IssueCountry]         
    end  
    
    unless args[:NationalityCountry].nil?
      document_section[:NationalityCountry] = args[:NationalityCountry]         
    end      
    
    return document_section
  end

  # Build the Visa section. Visa section is under the AdvancePassenger.Document section.
  # 
  # @param [Hash] args The args hash.
  # @option args [String] :issue_date The visa issue date.
  # @option args [String] :applicable_country The applicable country.
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
  
  # Build the PersonName section. PersonName section is under the AdvancePassenger section.
  # 
  # @param [Hash] args The args hash.
  # @option args [String] :@DateOfBirth "DateOfBirth" follows this format: YYYY-MM-DD.  
  # @option args [String] :@DocumentHolder "DocumentHolder" is used to identify the primary passport holder when the passport document is issued for multiple passengers.
  # @option args [String] :@Gender "Gender" can be "M" or "F" value.
  # @option args [String] :@NameNumber Assigned "NameNumber". 
  # @option args [String] :GivenName Given first name.
  # @option args [String] :MiddleName Given middle name.
  # @option args [String] :Surname Given last name.
  # @return args [Hash] Return a hash representing the PersonName section.
  def self.build_advance_passenger_person_name_section(args)
    defaults = {}
    args.merge!(defaults)
    
    person_name_section = Hash.new
    
    unless args[:@DateOfBirth].nil?
      person_name_section[:@DateOfBirth] = args[:@DateOfBirth]         
    end  

    unless args[:@DocumentHolder].nil?
      person_name_section[:@DocumentHolder] = args[:@DocumentHolder]         
    end    
    
    unless args[:@Gender].nil?
      person_name_section[:@Gender] = args[:@Gender]         
    end   
    
    unless args[:@NameNumber].nil?
      person_name_section[:@NameNumber] = args[:@NameNumber].upcase         
    end  
    
    unless args[:GivenName].nil?
      person_name_section[:GivenName] = args[:GivenName].upcase         
    end   
    
    unless args[:MiddleName].nil?
      person_name_section[:MiddleName] = args[:MiddleName].upcase         
    end   
    
    unless args[:Surname].nil?
      person_name_section[:Surname] = args[:Surname]         
    end      
    
    return person_name_section
  end 
  
  # Build the ContactNumber section. ContactNumber section is under the ContactInfo section.
  # 
  # @param [Hash] args The args hash.
  # @option args [String] :@NameNumber "NameNumber" is used to specify a passenger name number.  
  # @option args [String] :@Phone "Phone" is used to add customer telephone numbers into the record if applicable.  
  # @option args [String] :@PhoneUseType "PhoneUseType" is used to specify if the number is agency, "A," home, "H," business, "B," or fax, "F".  
  # @return args [Hash] Return a hash representing the ContactNumber section.
  def self.build_contact_info_contact_number_section(args)
    defaults = {}
    args.merge!(defaults)
    
    contact_number_section = Hash.new
    
    unless args[:@NameNumber].nil?
      contact_number_section[:@NameNumber] = args[:@NameNumber]         
    end  

    unless args[:@Phone].nil?
      contact_number_section[:@Phone] = args[:@Phone]         
    end  
    
    unless args[:@PhoneUseType].nil?
      contact_number_section[:@PhoneUseType] = args[:@PhoneUseType]         
    end  
    
    return contact_number_section
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
    document_section = PassengerDetail.build_advance_passenger_document_section(
      :@ExpirationDate    => "2018-05-26", 
      :@Number            => "1234567890",
      :@Type              => "P",
      :IssueCountry       => "FR",
      :NationalityCountry => "FR"
    )  
    
    person_name_section = PassengerDetail.build_advance_passenger_person_name_section(
      :@DateOfBirth       => "1980-12-02",
      :@DocumentHolder    => "true",
      :@Gender            => "M", 
      :@NameNumber        => "1.1",
      :GivenName          => "James",
      :MiddleName         => "Malcolm",
      :Surname            => "Green", 
    )
    
    contact_number_section = PassengerDetail.build_contact_info_contact_number_section(
      :@NameNumber        => "1.1",
      :@Phone             => "817-555-1212",
      :@PhoneUseType      => "H",  
    )
    
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
              
              "v:Document"    => document_section,
              "v:PersonName"  => person_name_section,
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
            "v:ContactNumber" => contact_number_section, 
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
