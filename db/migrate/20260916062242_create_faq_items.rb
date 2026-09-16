class CreateFaqItems < ActiveRecord::Migration[8.1]
  def change
    create_table :faq_items do |t|
      t.string :question
      t.text :answer
      t.integer :position

      t.timestamps
    end
  end
end
