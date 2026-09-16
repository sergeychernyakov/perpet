class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.string :tag
      t.text :excerpt
      t.text :body
      t.string :read_time
      t.integer :position

      t.timestamps
    end
  end
end
