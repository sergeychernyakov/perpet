class CreateSupportChannels < ActiveRecord::Migration[8.1]
  def change
    create_table :support_channels do |t|
      t.string :title
      t.string :availability
      t.text :description
      t.string :value
      t.string :href
      t.integer :position

      t.timestamps
    end
  end
end
