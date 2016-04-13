class Api::V1::SabreSessionController < Api::V1::BaseController
  
  # POST /api/sabre_session/create_session
  # POST /api/sabre_session/create_session, {}, { "Accept" => "application/vnd.deferointernational.com; version=1" }
  # POST /api/sabre_session/create_session?version=1
  # POST /api/v1/sabre_session/create_session
  def create_session
    
    # @TODO
    
    success_response([], :created)  
  end
  
end
