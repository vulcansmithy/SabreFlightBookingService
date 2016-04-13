require "rails_helper"

describe Api::V1::SabreSessionController do

  it "should be able to successfully create a Sabre Session Token" do
    
    # call the API endpoint
    post "/api/sabre_session/create_session"
    
    expect(response.code).to eq "201"

    binary_security_token = JSON.parse(response.body)["binary_security_token"]
    expect(binary_security_token.nil?).to eq false
    
    puts "@DEBUG #{__LINE__}    binary_security_token='#{binary_security_token}'"
  end

end
