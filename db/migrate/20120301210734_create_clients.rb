class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
      t.string :avatar_url
      t.string :city
      t.date :birth_date

      t.timestamps
    end
  end
end
