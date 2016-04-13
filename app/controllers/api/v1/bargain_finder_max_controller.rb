class Api::V1::BargainFinderMaxController < Api::V1::BaseController
  
  # == Constants ==============================================================
  MISSING_REQUIRED_SABRE_SESSION_TOKEN                 = "Missing required Sabre session token."
  MISSING_REQUIRED_ORIGIN_AND_DESTINATION_INFO         = "Missing required origin and destination information."
  MISSING_REQUIRED_PASSENGER_TYPES_AND_QUANTITIES_INFO = "Missing required passenger types and quantities information."
  WAS_NOT_ABLE_TO_ESTABLISH_A_SABRE_SESSION            = "Wasn't able to establish a Sabre Session."
  UNABLE_TO_DO_A_BARGAIN_FINDER_MAX_REQUEST            = "Something went wrong. Was not able to execute a Bargain Finder Max request."
  
  # == API Endpoints ==========================================================
  # GET  /api/bargain_finder_max/execute_bargain_finder_max_one_way
  # GET  /api/bargain_finder_max/execute_bargain_finder_max_one_way, {}, { "Accept" => "application/vnd.deferointernational.com; version=1" }
  # GET  /api/bargain_finder_max/execute_bargain_finder_max_one_way?version=1
  # GET  /api/v1/bargain_finder_max/execute_bargain_finder_max_one_way
  def execute_bargain_finder_max_one_way
    
    raise MISSING_REQUIRED_SABRE_SESSION_TOKEN if params[:sabre_session_token].nil?
    sabre_session_token = params[:sabre_session_token]

    raise MISSING_REQUIRED_ORIGIN_AND_DESTINATION_INFO if params[:origin_and_destination].nil?
    origin_and_destination = params[:origin_and_destination].first

    raise MISSING_REQUIRED_PASSENGER_TYPES_AND_QUANTITIES_INFO if params[:passenger_types_and_quantities].nil?
    passenger_types_and_quantities = params[:passenger_types_and_quantities]


    # instantiate a new SabreSession object
    session = SabreSession.new 
    
    # for now, set it to non-production
    session.set_to_non_production
    
    # connect to Sabre and wrap the new session to an existing Sabre session token
    call_result = session.establish_session(sabre_session_token)
    raise WAS_NOT_ABLE_TO_ESTABLISH_A_SABRE_SESSION if call_result[:status] == :failed
    
    # instantiate a new BargainFinderMax object
    bargain_finder_max = BargainFinderMax.new
    bargain_finder_max.establish_connection(session)
    
    # @TODO rename air_availability_one_way
    call_result = bargain_finder_max.air_availability_one_way([ origin_and_destination ], passenger_types_and_quantities)
    if call_result[:status] == :success
      success_response(call_result[:data], :ok)  
    else
      error_response(UNABLE_TO_DO_A_BARGAIN_FINDER_MAX_REQUEST, :bad_request)  
    end    
  end  

end
