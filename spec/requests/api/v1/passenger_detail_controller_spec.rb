require "rails_helper"

describe Api::V1::PassengerDetailController do
  
  it "should be able to successfully call the PassengerDetail API endpoint" do
    
    # establish a new Sabre session
    post "/api/sabre_session/create_session"
    expect(response.code).to eq "201"
    
  end

end
