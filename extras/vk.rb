class VK

	def initialize(params = nil)
		params ||= Hash.new
		@client = VK.oauth2_client
		@code = params[:code] if params[:code]
		self.token = params[:token] if params[:token]
		if (@token.nil? && @code)
			@token = VK.oauth2_get_token(@client, @code)
		end
	end
	
	def authorize_url(redirect_uri)	  
		@client.auth_code.authorize_url({
			:client_id => CFG["VK_APP_ID"],
			:scope => 'friend,groups',
			:redirect_uri => redirect_uri,
			:response_type => 'code'
		})
	end
	
	def token
		return @token if @token
		return nil if @code.nil?
		@token = VK.oauth2_get_token(@client, @code)
	end
	
	def token=(access_token)
		@token = OAuth2::AccessToken.new(@client, access_token)
	end
	
	def request(method, prms)
		method ||= 'users.get'
		params = prms || Hash.new		
		params.merge!({
			'format' => 'JSON',
			'access_token' => @token.token
		})
		response = @token.get("#{CFG["VK_API_URL"]}/#{method}", :params => params)		
		Rails.logger.debug "Response: #{response.body}"
		if (response.parsed['error'])
			raise "VkError: method #{method} with params #{params} raised error #{response.parsed['error']}"
		else
			response.parsed['response']
		end
	end
	
	def users_get(uids, fields = '', name_case = '')
		uids = uids.join(',') if uids.instance_of? Array
		params = {'uids' => uids}
		params['fields'] = fields if !fields.empty?
		params['name_case'] = name_case if !name_case.empty?		
		request('users.get', params)
	end
	
	def user_get(uid)
		users = users_get(uid)
		users[0]
	end
	
	def groups_get_members(count = 30, offset = 0)
		request('groups.getMembers', {
			'gid' => CFG["VK_GROUP_ID"],
			'count' => count,
			'offset' => offset
		})
	end
	
	def groups_get(query, count = 30, offset = 0)
	  request('groups.search', {
      'q' => query,
      'count' => count,
      'offset' => offset
    })
	end
	
	class << self
	
		def oauth2_client
			OAuth2::Client.new(CFG["VK_APP_ID"], CFG["VK_APP_SECRET"], {
				:authorize_url => CFG["VK_AUTH_URL"],
				:token_url => CFG["VK_TOKEN_URL"]
			})
		end
		
		def oauth2_get_token(client, code)
			client.get_token({
				:client_id => CFG["VK_APP_ID"],
				:client_secret => CFG["VK_APP_SECRET"],
				:code => code
			})
		end
	end
end