class AddVkIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :vk_id, :integer
  end
end
