class User < ActiveRecord::Base
  #attr_accessible :name, :vk_id, :vk_token, :vk_expire
  
  validates :name, :presence => true
  validates :vk_id, :presence => true, :uniqueness => true
  validates :vk_token, :presence => true
end
