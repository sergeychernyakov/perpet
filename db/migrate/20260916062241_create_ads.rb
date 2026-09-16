class CreateAds < ActiveRecord::Migration[8.1]
  def change
    create_table :ads do |t|
      t.string :title
      t.string :kind
      t.string :city
      t.string :period
      t.string :price
      t.text :description
      t.string :icon
      t.string :status
      t.date :published_on
      t.references :profile, null: true, foreign_key: true

      t.timestamps
    end

    add_index :ads, :kind
    add_index :ads, :status
  end
end
