class AddSearchTextToAds < ActiveRecord::Migration[8.1]
  def change
    add_column :ads, :search_text, :string
  end
end
