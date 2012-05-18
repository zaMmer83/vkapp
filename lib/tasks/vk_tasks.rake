namespace :vk do
  desc "Fill clients with users from group"
  task :populate_clients => :environment do
		user = User.find(ENV['USER'] || 0)
		return if user.nil?
		ActiveRecord::Base.connection.execute('TRUNCATE TABLE clients')
		load_all_clients(user.vk_token)
  end
	
	task :load_clients => :environment do
		count = ENV['COUNT'] || 30
		offset = ENV['OFFSET'] || 0
	end
	
	task :load_new_clients => :environment do
	  user = User.find(ENV['USER'] || 0)
    return if user.nil?
		load_new_clients(user.vk_token)
	end
end

def load_all_clients(token)
	vk = VK.new(:token => token)
	response = vk.groups_get_members(0, 0)
	size = response['count']
	#size = 50
	volume, offset = 100, 0
	while offset <= size do
  	response = vk.groups_get_members(volume, offset)		
  	cids = response['users']
  	sleep(1)
  	clients = vk.users_get(cids, 'bdate,city,photo_medium')
		clients.each do |client|
			Client.create({
				:vk_id => client['uid'],
				:name => "#{client['first_name']} #{client['last_name']}",
				:avatar_url => client['photo_medium'],
				:city => client['city'],
				:birth_date => client['bdate']
			})
		end
		sleep(1)
		offset += volume
	end	
end

def load_new_clients(token)
  vk = VK.new(:token => token)
  response = vk.groups_get_members(0, 0)
  size = response['count']
  # size = 300
  volume, offset = 100, 0
  new_cids = []
  while offset <= size do
    response = vk.groups_get_members(volume, offset)    
    cids = response['users']
    existing = Client.where(:vk_id => cids).all.map(&:vk_id)
    new_cids += cids - existing
    sleep(1)
    offset += volume
  end
  new_cids.uniq!
  new_cids.each_slice(volume) do |chunk|
    clients = vk.users_get(chunk.to_json, 'bdate,city,photo_medium')
    clients.each do |client|
      Client.create({
        :vk_id => client['uid'],
        :name => "#{client['first_name']} #{client['last_name']}",
        :avatar_url => client['photo_medium'],
        :city => client['city'],
        :birth_date => client['bdate']
      })
    end
    sleep(1)
  end    
end
