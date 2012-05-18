module ApplicationHelper

	def current_token=(token)
    @token = token
    session[:token] = token.token
  end

  def current_token
		@token ||= token_from_remember_token
		#logger.debug "Token: #{@token.token}"
  end
	
	def check_token
		begin
			self.current_token = vk_oauth2_token(vk_oauth2_client) if current_token.nil?			
		rescue => e
			logger.debug oauth2_error(e)
		end
	end
	
	def oauth2_error(e)
		if (e.is_a? OAuth2::Error)
			"#{e}: (code: #{e.code}, description: #{e.description}, response: #{e.response.body}"
		else
			"#{e}"
		end
	end
	
	def current_user=(user)	  
    if (!user.nil?)
      @user = user
      session[:user_id] = user.id
    else      
      session[:user_id] = nil
    end    
  end
  
  def current_user
		return nil if session[:user_id].nil?
		@user = User.find_by_id(session[:user_id])
	end
	
	def authenticate
		redirect_to home_path if self.current_user.nil? 		
	end
	
	private
  
    def token_from_remember_token
			#logger.debug "Session: #{session[:token]}"
			return nil if session[:token].nil?
			OAuth2::AccessToken.new(vk_oauth2_client, session[:token])      
    end

end
