# В макете 2.0 объявления разделены на два раздела — питомцы и ситтеры,
# а в карточке появились возраст, порода и деятельность. У профиля к тому же
# есть телефон и рассказ о себе: их показывает «Карточка пользователя».
class AddDesignFieldsToAdsAndProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :ads, :role, :string, default: "pet", null: false
    add_column :ads, :age, :string
    add_column :ads, :breed, :string
    add_column :ads, :activity, :string
    add_index :ads, :role

    add_column :profiles, :age, :string
    add_column :profiles, :activity, :string
    add_column :profiles, :about, :text
    add_column :profiles, :phone, :string
  end
end
