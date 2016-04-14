class Api::V1::BargainFinderMaxController < Api::V1::BaseController
  
  # == Constants ==============================================================
  MISSING_ORIGIN_AND_DESTINATION_PARAMS         = "'origin_and_destination' parameters where not passed. Said parameter is a required parameter."
  MISSING_PASSENGER_TYPES_AND_QUATITIES_PARAMS  = "'passenger_types_and_quantities' parameters where not passed. Said parameter is a required parameter."
  BARGAIN_FINDER_MAX_REQUEST_UNSUCCESSFUL       = "Request unsuccessful. Unable to perform BargainFinderMax request."
  
  # == API Endpoints ==========================================================
  # GET  /api/bargain_finder_max/execute_bargain_finder_max_one_way
  # GET  /api/bargain_finder_max/execute_bargain_finder_max_one_way, {}, { "Accept" => "application/vnd.deferointernational.com; version=1" }
  # GET  /api/bargain_finder_max/execute_bargain_finder_max_one_way?version=1
  # GET  /api/v1/bargain_finder_max/execute_bargain_finder_max_one_way
  def execute_bargain_finder_max_one_way
    
    raise MISSING_REQUIRED_SABRE_SESSION_TOKEN if params[:sabre_session_token].nil?
    sabre_session_token = params[:sabre_session_token]

    raise MISSING_ORIGIN_AND_DESTINATION_PARAMS if params[:origin_and_destination].nil?
    origin_and_destination = params[:origin_and_destination].first

    raise MISSING_PASSENGER_TYPES_AND_QUATITIES_PARAMS if params[:passenger_types_and_quantities].nil?
    passenger_types_and_quantities = params[:passenger_types_and_quantities]

    session = SabreSession.new 
    session.set_to_non_production
    
    call_result = session.establish_session(sabre_session_token)
    raise UNABLE_TO_ESTABLISH_A_SABRE_SESSION if call_result[:status] == :failed
    
    bargain_finder_max = BargainFinderMax.new
    bargain_finder_max.establish_connection(session)
    
    # @TODO rename air_availability_one_way
    call_result = bargain_finder_max.air_availability_one_way([ origin_and_destination ], passenger_types_and_quantities)
    if call_result[:status] == :success
      success_response(call_result[:data], :ok)  
    else
      error_response(BARGAIN_FINDER_MAX_REQUEST_UNSUCCESSFUL, :bad_request)  
    end    
  end  

end
