class Api::V1::PassengerDetailController < Api::V1::BaseController
  
  # == Constants ==============================================================
  MISSING_REQUIRED_DOCUMENT_ADVANCE_PASSENGER_INFO    = "Missing required document advance passenger information."
  MISSING_REQUIRED_PERSON_NAME_ADVANCE_PASSENGER_INFO = "Missing required person name advance passenger information."  
  MISSING_REQUIRED_CONTACT_NUMBER_CONTACT_INFO        = "Missing required contact number contact information."
  MISSING_REQUIRED_PERSON_NAME_CONTACT_INFO           = "Missing required person name contact information."
  UNABLE_TO_DO_A_PASSENGER_DETAIL_REQUEST             = "Request failed. Was not able to execute a Passenger Detail request."
  
  # == API Endpoints ==========================================================
  # POST /api/passenger_detail/execute_passenger_detail
  # POST /api/passenger_detail/execute_passenger_detail, {}, { "Accept" => "application/vnd.deferointernational.com; version=1" }
  # POST /api/passenger_detail/execute_passenger_detail?version=1
  # POST /api/v1/passenger_detail/execute_passenger_detail
  def execute_passenger_detail
    
    raise MISSING_REQUIRED_SABRE_SESSION_TOKEN if params[:sabre_session_token].nil?
    sabre_session_token = params[:sabre_session_token]
    
    raise MISSING_REQUIRED_DOCUMENT_ADVANCE_PASSENGER_INFO if params[:document_advance_passenger].nil?
    document_advance_passenger = params[:document_advance_passenger]

    raise MISSING_REQUIRED_PERSON_NAME_ADVANCE_PASSENGER_INFO if params[:person_name_advance_passenger].nil?
    person_name_advance_passenger = params[:person_name_advance_passenger]
    
    raise MISSING_REQUIRED_CONTACT_NUMBER_CONTACT_INFO if params[:contact_number_contact_info].nil?
    contact_number_contact_info = params[:contact_number_contact_info]
    
    raise MISSING_REQUIRED_PERSON_NAME_CONTACT_INFO if params[:person_name_contact_info].nil?
    person_name_contact_info = params[:person_name_contact_info]
    
    session = SabreSession.new 
    session.set_to_non_production
    
    call_result = session.establish_session(sabre_session_token)
    raise UNABLE_TO_ESTABLISH_A_SABRE_SESSION if call_result[:status] == :failed
  
    passenger_detail = PassengerDetail.new
    passenger_detail.establish_connection(session)
    
    call_result = passenger_detail.execute_passenger_detail(
      :document_advance_passenger    => document_advance_passenger,
      :person_name_advance_passenger => person_name_advance_passenger,
      :contact_number_contact_info   => contact_number_contact_info,
      :person_name_contact_info      => person_name_contact_info
    )
    
    if call_result[:status] == :success
      success_response(call_result[:data], :created)  
    else
      error_response(UNABLE_TO_DO_A_PASSENGER_DETAIL_REQUEST, :bad_request)  
    end 
  end  
  
end
