class AddVkIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :vk_id, :string
    add_index :users, :vk_id, unique: true
  end
end
