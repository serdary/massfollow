require 'will_paginate/array'

class TwitterController < ApplicationController  
  respond_to :html, :json, :js
  
  # Lists profiles of logged in user's followees
  def index
    return unless current_user

    begin
      followees_ids = current_user.get_followees_ids(params[:page].to_i)
      return if followees_ids.blank?
      
      @paged_ids = followees_ids.paginate(:page => params[:page], :per_page => configatron.page_size)

      @followees = current_user.get_followees(@paged_ids)
    rescue Exception => ex
      logger.error "Error occured while getting followees, Ex: #{ex}"
    end
  end
  
  # Used to mass follow other users
  def follow
    process_msg = current_user.mass_change_friendship(params[:nicknames], 'follow')
    
    redirect_to root_url, :notice => process_msg 
  end
  
  # Used to mass unfollow other users
  def unfollow
    process_msg = current_user.mass_change_friendship(params[:nicknames], 'unfollow')
    
    redirect_to root_url, :notice => process_msg 
  end
  
  # Searches twitter to find relevant profile according to the search term
  def search
    begin
      @followees = current_user.search(params[:query]).paginate(:page => params[:page], :per_page => configatron.page_size)
    rescue Exception => ex
      logger.error "Error occured while searching for: #{params[:query]}, Ex: #{ex}"
    end
    respond_with(@followees, { :followees => @followees, :type => 'follow' })
  end
  
  # Logs a user out from app and twitter session.
  # It is intended to allow user logout from twitter as well. But apparently twitter does not allow that.
  def logout
    # There is no way to logout from twitter via API. (or at least I couldn't find any.)
    # So below will just terminate twitter session
    current_user.logout_from_twitter
    
    session[:user_id] = nil
    redirect_to root_url, :notice => 'Logged out'
  end
end
