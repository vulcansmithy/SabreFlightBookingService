require "rails_helper"

RSpec.describe Session, type: :model do
  
  it "should be able to instantiate a new Session and initialize the required configuration settings" do
    session = Session.new

    expect(session.username     ).to eq ENV["username"     ]
    expect(session.password     ).to eq ENV["password"     ]
    expect(session.ipcc         ).to eq ENV["ipcc"         ]
    expect(session.account_email).to eq ENV["account_email"]
    expect(session.domain       ).to eq ENV["domain"       ]
  end
  
end
