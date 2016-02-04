require "rails_helper"

RSpec.describe BargainFinderMax, type: :model do
  
  it "should do something" do
    session = Session.new
    session.create_session_token
    
    bfm = BargainFinderMax.new
    result = bfm.bfm_one_way(session)
  end

end
