class ApplicationController < ActionController::Base
  before_filter :current_user
  
  protect_from_forgery
  
  private
  
  def current_user
    begin
      @current_user = User.find(session[:user_id]) if session[:user_id]
    rescue ActiveRecord::RecordNotFound
      logger.error "Failure: Attempt to get user for session id: #{session[:user_id]}"
      session[:user_id] = nil
    end
  end
end
