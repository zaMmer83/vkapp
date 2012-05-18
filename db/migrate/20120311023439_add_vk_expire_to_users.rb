class AddVkExpireToUsers < ActiveRecord::Migration
  def change
    add_column :users, :vk_expire, :integer
  end
end
