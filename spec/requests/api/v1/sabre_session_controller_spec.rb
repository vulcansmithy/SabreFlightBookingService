require "rails_helper"

describe Api::V1::SabreSessionController do

  it "should be able to successfully create a Sabre Session Token" do
    
    # call the API endpoint
    post "/api/sabre_session/create_session"
    
    # expect a return code of successfully created or a response code equavalent to '201'
    expect(response.code).to eq "201"

    # retrieve the returned binary_security_token
    binary_security_token = JSON.parse(response.body)["binary_security_token"]
    
    # make sure binary_security_token is present and not have nil value
    expect(binary_security_token.nil?).to eq false

    # make sure the binary_security_token has the sub string value 'Shared/IDL:IceSess'  
    expect(binary_security_token.scan(/\AShared\/IDL:IceSess/).empty?).to eq false
  end

end
