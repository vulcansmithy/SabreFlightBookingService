require "rails_helper"

describe Api::V1::PassengerDetailController do
  
  it "should be able to successfully call the PassengerDetail API endpoint" do
    
    # establish a new Sabre session
    post "/api/sabre_session/create_session"
    expect(response.code).to eq "201"
    
    document_advance_passenger = PassengerDetail.build_advance_passenger_document_section(
      :@ExpirationDate    => "2018-05-26", 
      :@Number            => "1234567890",
      :@Type              => "P",
      :IssueCountry       => "FR",
      :NationalityCountry => "FR"
    ) 
    
    person_name_advance_passenger = PassengerDetail.build_advance_passenger_person_name_section(
      :@DateOfBirth       => "1980-12-02",
      :@DocumentHolder    => "true",
      :@Gender            => "M", 
      :@NameNumber        => "1.1",
      :GivenName          => "Charles",
      :MiddleName         => "Cambell",
      :Surname            => "Finley", 
    )
    contact_number_contact_info  = PassengerDetail.build_contact_info_contact_number_section(
      :@NameNumber        => "1.1",
      :@Phone             => "817-555-1212",
      :@PhoneUseType      => "H",  
    )
    
    person_name_contact_info = PassengerDetail.build_contact_info_person_name_section(
      :@Infant        => "false", 
      :@NameNumber    => "1.1",
      :@PassengerType => "ADT",
      :GivenName      => person_name_advance_passenger[:GivenName],
      :Surname        => person_name_advance_passenger[:Surname  ],
    ) 
    
    payload = {
      :sabre_session_token           => JSON.parse(response.body)["binary_security_token"],
      :document_advance_passenger    => document_advance_passenger,
      :person_name_advance_passenger => person_name_advance_passenger, 
      :contact_number_contact_info   => contact_number_contact_info,
      :person_name_contact_info      => person_name_contact_info, 
    }
    
    # call the Passenger Detail API endpoint
    post "/api/passenger_detail/execute_passenger_detail", payload
    expect(response.code).to eq "201"
    
    returned_data = JSON.parse(response.body)
    expect(returned_data.nil?).to eq false
    
    customer_info = returned_data["customer_info"]
    expect(customer_info.nil?).to eq false

    # make sure the returned_data contains the one passed to the API  
    expect((customer_info["person_name"])["given_name"]).to eq "CHARLES"
    expect((customer_info["person_name"])["surname"   ]).to eq "FINLEY"
  end

end
