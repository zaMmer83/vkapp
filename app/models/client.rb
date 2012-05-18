class Client < ActiveRecord::Base
  validates :vk_id, :presence => true
  
  default_scope :order => 'name'
  
  scope(:search, lambda do |search|
    if search =~ /\A\d+\Z/
      where("vk_id = ?", search)
    else
      where("name LIKE ?", "%#{search}%")    
    end
  end)
end
