class SessionsController < ApplicationController
  
  # Logs twitter user in. Creates a new user in local DB if he/she is a new user, or updates his/her columns
  def create  
    auth = request.env["omniauth.auth"]
    
    begin      
      # If user is signed in our app before, just update some twitter-specific fields.
      if user = User.find_by_uid_and_provider(auth["uid"], 'twitter')
        User.update_twitter_fields(user.id, auth)
      else
        user = User.create_twitter_user(auth)
      end
    rescue Exception => ex
      logger.error "Error occured while creating new user. Ex:#{ex}"
    end
    
    if user
      session[:user_id] = user.id
      redirect_to root_url, :notice => "Successfully signed in."
    else
      redirect_to root_url, :notice => "An error occured, please try again."
    end
  end
  
  # Logs a user out
  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => 'Logged out.'
  end
  
  # Called when an error occured after twitter callback, or when user does not give permission
  def failure
    msg = params["message"] == 'invalid_response' ? 'An error occured. Please try again.' : 'You need to give permission to use this app.'
    
    redirect_to root_url, :notice => msg
  end
end