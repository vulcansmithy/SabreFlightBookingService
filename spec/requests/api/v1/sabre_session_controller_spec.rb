require "rails_helper"

describe Api::V1::SabreSessionController do

  it "should be able to successfully create a Sabre Session Token" do
    
    # call the API endpoint
    post "/api/sabre_session/create_session"
    
    expect(response.code).to eq "201"
  end

end
