require "rails_helper"

RSpec.describe PassengerDetail, type: :model do
  
  it "should be able to receive :passenger_details_rq when executing available_operations" do
    
    session = SabreSession.new
    session.set_to_non_production
    result = session.establish_session
    
    expect(result[:status]).to eq :success
    
    passenger_detail = PassengerDetail.new
    passenger_detail.establish_connection(session)
    
    expect(passenger_detail.available_operations.first).to eq :passenger_details_rq
  end  

  it "should be able to execute a PassengerDetailRQ" do
    
    session = SabreSession.new
    session.set_to_non_production
    result = session.establish_session
    
    expect(result[:status]).to eq :success
    
    passenger_detail = PassengerDetail.new
    passenger_detail.establish_connection(session)
    
    
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
    
    result = passenger_detail.execute_passenger_detail(
      :document_advance_passenger    => document_advance_passenger,
      :person_name_advance_passenger => person_name_advance_passenger,
      :contact_number_contact_info   => contact_number_contact_info,
      :person_name_contact_info      => person_name_contact_info
    )

    expect(result[:status]).to eq :success
  end  
  
end
