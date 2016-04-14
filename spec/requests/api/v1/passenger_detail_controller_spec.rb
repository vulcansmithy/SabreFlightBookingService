require "rails_helper"

describe Api::V1::PassengerDetailController do
  
  it "should be able to successfully call the PassengerDetail API endpoint" do
    
    # establish a new Sabre session
    post "/api/sabre_session/create_session"
    expect(response.code).to eq "201"
    
    payload = {
      :sabre_session_token           => JSON.parse(response.body)["binary_security_token"],
      :document_advance_passenger    => { :@ExpirationDate => "2018-05-26", :@Number         => "1234567890",   :@Type          => "P",   :IssueCountry => "FR",      :NationalityCountry => "FR"                                                      },
      :person_name_advance_passenger => { :@DateOfBirth    => "1980-12-02", :@DocumentHolder => "true",         :@Gender        => "M",   :@NameNumber  => "1.1",     :GivenName          => "Charles", :MiddleName => "Cambell", :Surname => "Finley" }, 
      :contact_number_contact_info   => { :@NameNumber     => "1.1",        :@Phone          => "817-555-1212", :@PhoneUseType  => "H"                                                                                                                 },
      :person_name_contact_info      => { :@Infant         => "false",      :@NameNumber     => "1.1",          :@PassengerType => "ADT", :GivenName    => "Charles", :Surname            => "Finley"                                                  }, 
    }
    
    post "/api/passenger_detail/execute_passenger_detail", payload
    expect(response.code).to eq "201"
    
    travel_itinerary = JSON.parse(response.body)["travel_itinerary"]
    expect(travel_itinerary.nil?).to eq false
    
    puts "@DEBUG #{__LINE__}    #{ap travel_itinerary}"
  end

end
