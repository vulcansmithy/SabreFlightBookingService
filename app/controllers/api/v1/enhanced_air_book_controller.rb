class Api::V1::EnhancedAirBookController < Api::V1::BaseController
  
  # == Constants ==============================================================
  MISSING_FLIGHT_SEGMENTS_PARAMS         = "'flight_segments' parameters where not passed. Said parameter is a required parameter."   
  ENHANCED_AIR_BOOK_REQUEST_UNSUCCESSFUL = "Request unsuccessful. Unable to perform EnhancedAirBook request."
  
  # == API Endpoints ==========================================================
  # POST /api/enhanced_air_book/execute_enhanced_air_book
  # POST /api/enhanced_air_book/execute_enhanced_air_book, {}, { "Accept" => "application/vnd.deferointernational.com; version=1" }
  # POST /api/enhanced_air_book/execute_enhanced_air_book?version=1
  # POST /api/v1/enhanced_air_book/execute_enhanced_air_book
  def execute_enhanced_air_book
    
    raise MISSING_REQUIRED_SABRE_SESSION_TOKEN if params[:sabre_session_token].nil?
    sabre_session_token = params[:sabre_session_token]
    
    raise MISSING_FLIGHT_SEGMENTS_PARAMS if params[:flight_segments].nil?
    parsed_json_params = JSON.parse(params[:flight_segments])
    
    flight_segments = []
    parsed_json_params.each do |segment|
      flight_segments << segment.symbolize_keys
    end

    session = SabreSession.new 
    session.set_to_non_production
    
    call_result = session.establish_session(sabre_session_token)
    raise UNABLE_TO_ESTABLISH_A_SABRE_SESSION if call_result[:status] == :failed
    
    enhanced_air_book = EnhancedAirBook.new
    enhanced_air_book.establish_connection(session)
    
    call_result = enhanced_air_book.execute_request(flight_segments: flight_segments)
    
    if call_result[:status] == :success
      # @TODO for some reason, what the API callee is getting is status code of 200 (ok) and not 201 (created)
      success_response({ "status" => :created, "data" => call_result[:data] }, :created)  
    else
      error_response(ENHANCED_AIR_BOOK_REQUEST_UNSUCCESSFUL, :bad_request)  
    end 
  end  
  
end
