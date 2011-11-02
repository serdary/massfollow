class User < ActiveRecord::Base
  # Used to create a new user from twitter user info.
  # Called when a new twitter wants to connect to great mass follow app in sessionscontroller#create
  def self.create_twitter_user(auth)
    auth["user_info"] ||= {}
    
    User.create!(:uid => auth["uid"], :nickname => auth["user_info"]["nickname"], 
      :name => auth["user_info"]["name"], :provider => 'twitter', :token => auth['credentials']['token'], 
      :secret => auth['credentials']['secret'], :followee_count => self.extract_followee_count(auth))
  end
  
  # Updates a user's twitter specific fields to keep up to date twitter token & name & nickname
  def self.update_twitter_fields(id, auth)
    auth["user_info"] ||= {}
    
    User.update(id, :nickname => auth["user_info"]["nickname"], :name => auth["user_info"]["name"], 
      :token => auth['credentials']['token'], :secret => auth['credentials']['secret'], :followee_count => self.extract_followee_count(auth))
  end
  
  # Extracts user's friends count from auth
  def self.extract_followee_count(auth)
    auth['extra']['user_hash'].blank? ? 0 : auth['extra']['user_hash']['friends_count']
  end
  
  # Used to mass change friendship of the user
  # type = ['follow', 'unfollow']
  def mass_change_friendship(users, type)
    return '' if users.blank?
    
    failed_nicknames = Array.new  # holds failed nicknames to be able to warn the user
    users.each do |nickname|
      begin
        failed_nicknames.push(nickname) if ! change_friendship(nickname, type)
      rescue Exception => ex
        failed_nicknames.push(nickname)
        logger.error "Error occured: #{type} a user with nickname: #{nickname}, Ex: #{ex}"
      end
    end
    
    # Update user's followee count
    self.followee_count = get_friend_count
    save

    if failed_nicknames.empty?
      process_msg = "#{type.capitalize} operation has been successfully performed for these users: " + users.join(', ')
    else
      process_msg = "#{type.capitalize} operation has been completed with errors for these users: " + failed_nicknames.join(', ')
    end
    process_msg
  end
  
  # Used to get followees of the signed in user with given paged/sliced friends ids
  def get_followees(ids)
    followees_resp = twitter_user.request(:get, configatron.api_call_url + "users/lookup.json?user_id=#{ids.join(',')}")
    
    if followees_resp.is_a?(Net::HTTPSuccess)
      get_nicknames_and_names(JSON.parse(followees_resp.body))
    end
  end
  
  # Used to get ids of the followees for the signed in user
  def get_followees_ids(page)
    page ||= 0
    # To get friend ids, we need to supply a cursor which starts at -1 and has bucket size of 5000 (https://dev.twitter.com/docs/api/1/get/friends/ids)
    cursor = (((page*configatron.page_size)+configatron.page_size) / 5000).floor - 1
    
    followees_ids_resp = twitter_user.request(:get, configatron.api_call_url + "friends/ids.json", { 'cursor' => cursor.to_s })
    
    ids = JSON.parse(followees_ids_resp.body) if followees_ids_resp.is_a?(Net::HTTPSuccess)
    return ids['ids'] if ids
  end
  
  # Searches by the query user entered and returns nicknames of the found users
  def search(query)
    response = twitter_user.request(:get, configatron.api_call_url + "users/search.json?q=#{URI.escape(query)}")
    
    #"#{configatron.api_call_url}users/search.json?q=#{URI.escape(query)}&page=#{page}&per_page=#{configatron.page_size}"
    if response.is_a?(Net::HTTPSuccess)
      get_nicknames_and_names(JSON.parse(response.body))
    end
  end
  
  # Ends the session but cannot sign outs from twitter. Couldn't find a way to sign out from twitter via API
  def logout_from_twitter
    response = twitter_user.request(:post, configatron.api_call_url + "account/end_session.json")
  end
  
  # Used to get friend count of the logged in user to update after changing relationship
  def get_friend_count
    response = twitter_user.request(:get, configatron.api_call_url + "account/totals.json")
    
    if response.is_a?(Net::HTTPSuccess)
      body = JSON.parse(response.body)
      body["friends"]
    end
  end
  
  # Helper methods #
  
  # Used to display current user at hello message
  def screen_name
    name || nickname
  end
  
  private
  
  # Returns an access token for the current user
  def twitter_user
    @twitter_user ||= prepare_access_token(self.token, self.secret)
  end
  
  # Prepares an access token for the current user
  def prepare_access_token(oauth_token, oauth_token_secret)
    consumer = OAuth::Consumer.new(configatron.consumer_key, configatron.consumer_secret, { :site => configatron.tw_api_url })
    
    token_hash = { :oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret }
    OAuth::AccessToken.from_hash(consumer, token_hash)
  end
  
  # Collects all user nicknames from users hash list and returns
  def get_nicknames_and_names(users)
    list = []
    users.each do |user|
      list.push({ :nickname => get_nickname(user), :name => get_name(user) })
    end
    
    return list
  end
  
  # Extracts a user's nickname from hash and returns
  def get_nickname(user_info)
    return user_info["screen_name"]
  end
  
  # Extracts a user's name from hash and returns
  def get_name(user_info)
    return user_info["name"]
  end
  
  # Changes friendship of 'nickname' user according to type param.
  # type = {'follow', 'unfollow'}
  def change_friendship(nickname, type)
    if type == 'follow'
      result = twitter_user.request(:post, configatron.api_call_url + "friendships/create.json", {:screen_name => nickname})
    elsif type == 'unfollow'
      result = twitter_user.request(:post, configatron.api_call_url + "friendships/destroy.json", {:screen_name => nickname})
    end

    result.is_a?(Net::HTTPSuccess)
  end
end