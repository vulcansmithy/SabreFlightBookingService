require "rails_helper"

RSpec.describe EnhancedAirBook, type: :model do
  
  it "should be able to execute EnhancedAirBookRQ request" do
    
    session = Session.new
    session.set_to_non_production
    session.establish_session
    
    enhanced_air_book = EnhancedAirBook.new
    enhanced_air_book.establish_connection(session)
    
    enhanced_air_book.execute_enhanced_air_book
  end  
  
end
