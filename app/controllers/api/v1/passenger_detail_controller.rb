class Api::V1::PassengerDetailController < Api::V1::BaseController
  
  # == Constants ==============================================================
  MISSING_DOCUMENT_ADVANCE_PASSENGER_PARAMS    = "'document_advance_passenger' parameters where not passed. Said parameter is a required parameter."   
  MISSING_PERSON_NAME_ADVANCE_PASSENGER_PARAMS = "'person_name_advance_passenger' parameters where not passed. Said parameter is a required parameter."      
  MISSING_CONTACT_NUMBER_CONTACT_INFO_PARAMS   = "'contact_number_contact_info' parameters where not passed. Said parameter is a required parameter."   
  MISSING_PERSON_NAME_CONTACT_INFO_PARAMS      = "'person_name_contact_info' parameters where not passed. Said parameter is a required parameter."  
  PASSENGER_DETAIL_REQUEST_UNSUCCESSFUL        = "Request unsuccessful. Unable to perform PassengerDetail request."  

  # == API Endpoints ==========================================================
  # POST /api/passenger_detail/execute_passenger_detail
  # POST /api/passenger_detail/execute_passenger_detail, {}, { "Accept" => "application/vnd.deferointernational.com; version=1" }
  # POST /api/passenger_detail/execute_passenger_detail?version=1
  # POST /api/v1/passenger_detail/execute_passenger_detail
  def execute_passenger_detail
    
    raise MISSING_REQUIRED_SABRE_SESSION_TOKEN if params[:sabre_session_token].nil?
    sabre_session_token = params[:sabre_session_token]
    
    raise MISSING_DOCUMENT_ADVANCE_PASSENGER_PARAMS if params[:document_advance_passenger].nil?
    document_advance_passenger = JSON.parse(params[:document_advance_passenger]).symbolize_keys
    puts "@DEBUG #{__LINE__}    document_advance_passenger=#{ap document_advance_passenger}"
    
    raise MISSING_PERSON_NAME_ADVANCE_PASSENGER_PARAMS if params[:person_name_advance_passenger].nil?
    person_name_advance_passenger = JSON.parse(params[:person_name_advance_passenger]).symbolize_keys
    
    raise MISSING_CONTACT_NUMBER_CONTACT_INFO_PARAMS if params[:contact_number_contact_info].nil?
    contact_number_contact_info = JSON.parse(params[:contact_number_contact_info]).symbolize_keys
    
    raise MISSING_PERSON_NAME_CONTACT_INFO_PARAMS if params[:person_name_contact_info].nil?
    person_name_contact_info = JSON.parse(params[:person_name_contact_info]).symbolize_keys
    
    session = SabreSession.new 
    session.set_to_non_production
    
    call_result = session.establish_session(sabre_session_token)
    raise UNABLE_TO_ESTABLISH_A_SABRE_SESSION if call_result[:status] == :failed
  
    passenger_detail = PassengerDetail.new
    passenger_detail.establish_connection(session)
    
    call_result = passenger_detail.execute_request(
      :document_advance_passenger    => document_advance_passenger,
      :person_name_advance_passenger => person_name_advance_passenger,
      :contact_number_contact_info   => contact_number_contact_info,
      :person_name_contact_info      => person_name_contact_info
    )
    
    if call_result[:status] == :success
      success_response(call_result[:data], :created)  
    else
      error_response(PASSENGER_DETAIL_REQUEST_UNSUCCESSFUL, :bad_request)  
    end 
  end  
  
end
