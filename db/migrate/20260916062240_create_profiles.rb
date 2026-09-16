class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.string :name
      t.string :city
      t.string :email
      t.string :pet_name
      t.string :pet_age

      t.timestamps
    end
  end
end
