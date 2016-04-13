class Api::V1::SabreSessionController < Api::V1::BaseController
  
  # == Constants ==============================================================
  SABRE_SESSION_WAS_NOT_CREATED = "Request failed. Sabre Session was not able  to be created."
  
  # == API Endpoints ==========================================================
  # POST /api/sabre_session/create_session
  # POST /api/sabre_session/create_session, {}, { "Accept" => "application/vnd.deferointernational.com; version=1" }
  # POST /api/sabre_session/create_session?version=1
  # POST /api/v1/sabre_session/create_session
  def create_session
    # instantiate a SabreSession object
    session = SabreSession.new
    
    # for now, set it to non-production
    session.set_to_non_production
    
    # establish a Sabre Session
    call_result = session.establish_session
    
    if call_result[:status] == :success
      success_response(call_result[:data], :created)  
    else
      error_response(SABRE_SESSION_WAS_NOT_CREATED, :bad_request)  
    end
  end  
  
end
