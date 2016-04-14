class Api::V1::EnhancedAirBookController < Api::V1::BaseController
  
  # == Constants ==============================================================
  MISSING_REQUIRED_FLIGHT_SEGMENT_INFO      = "Missing required flight segment(s) information."
  UNABLE_TO_DO_AN_ENHANCED_AIR_BOOK_REQUEST = "Request failed. Was not able to execute an Enhanced Air Book request."
  
  # == API Endpoints ==========================================================
  # POST /api/enhanced_air_book/execute_enhanced_air_book
  # POST /api/enhanced_air_book/execute_enhanced_air_book, {}, { "Accept" => "application/vnd.deferointernational.com; version=1" }
  # POST /api/enhanced_air_book/execute_enhanced_air_book?version=1
  # POST /api/v1/enhanced_air_book/execute_enhanced_air_book
  def execute_enhanced_air_book
    
    raise MISSING_REQUIRED_SABRE_SESSION_TOKEN if params[:sabre_session_token].nil?
    sabre_session_token = params[:sabre_session_token]
    
    raise MISSING_REQUIRED_DOCUMENT_ADVANCE_PASSENGER_INFO if params[:flight_segments].nil?
    flight_segments = params[:flight_segments]

    session = SabreSession.new 
    session.set_to_non_production
    
    call_result = session.establish_session(sabre_session_token)
    raise UNABLE_TO_ESTABLISH_A_SABRE_SESSION if call_result[:status] == :failed
    
    enhanced_air_book = EnhancedAirBook.new
    enhanced_air_book.establish_connection(session)
    
    call_result = enhanced_air_book.execute_enhanced_air_book(flight_segments: flight_segments)
    
    if call_result[:status] == :success
      success_response(call_result[:data], :created)  
    else
      error_response(UNABLE_TO_DO_AN_ENHANCED_AIR_BOOK_REQUEST, :bad_request)  
    end 
  end  
  
end
