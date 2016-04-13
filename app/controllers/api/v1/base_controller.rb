class Api::V1::BaseController < ApplicationController
  
  # == Instance methods =======================================================
  def success_response(data, status_code=:ok)
    render json: data, status: status_code
  end
  
  def error_response(message, status_code)    
    render json: { :message => message }, :status => status_code
  end
  
end
