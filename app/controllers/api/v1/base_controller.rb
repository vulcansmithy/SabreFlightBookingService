class Api::V1::BaseController < ApplicationController
  
  # == Constants ==============================================================
  MISSING_REQUIRED_SABRE_SESSION_TOKEN = "Missing Sabre session token paramter. Said parameter is a required parameter."
  UNABLE_TO_ESTABLISH_A_SABRE_SESSION  = "Was not able to establish a Sabre Session."
  
  # == Instance methods =======================================================
  def success_response(data, status_code=:ok)
    render json: data, status: status_code
  end
  
  def error_response(message, status_code)    
    render json: { :message => message }, :status => status_code
  end
  
end
