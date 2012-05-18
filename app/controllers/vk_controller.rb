class VkController < ApplicationController
  before_filter :authenticate, :except => [:home, :authorize, :login]
  
  def home    
  end

	def authorize
		vk = VK.new
		url_hash = { :host => CFG["VK_APP_HOST"], :action => 'login', :only_path => false }
		url_hash.merge!(:uid => @user.id) if @user && @user.respond_to?(:id)
		redirect_url = url_for(url_hash)
		redirect_to vk.authorize_url(redirect_url)
	end
	
	def login
		if @user.nil?
			user = build_user_from_vk(params[:code])			 
			if user.save
				self.current_user = user
				redirect_to clients_path
			else
			  self.current_user = nil			  
			  redirect_to home_path
			end
		else
		  redirect_to clients_path			
		end
	end
	
	def groups
	  if (!params[:search].blank?)
	    vk = VK.new(:token => @user.vk_token)
	    response = vk.groups_get(params[:search])
	    @size = response.shift
	    @groups = response.delete_if { |group| group['is_closed'] > 0 }
	  end
	end
	
	private
	
		def build_user_from_vk(code)
			begin
				vk = VK.new(:code => code)
				token = vk.token			
				vk_id = token.params['user_id']
				user = User.where(:vk_id => vk_id).first
				#logger.debug "user: #{user}"			
				if user.nil?
					response = vk.user_get(vk_id)				
					#logger.debug "Response: #{response}"	
					user = User.new(
						:name => "#{response['first_name']} #{response['last_name']}",
						:vk_id => vk_id,
						:vk_token => token.token,
						:vk_expire => token.expires_in
					)
				else
				  user.vk_token = token.token
				  user.vk_expire = token.expires_in
				end				
			rescue => e
				logger.debug oauth2_error(e)
			end
			user
		end

end
