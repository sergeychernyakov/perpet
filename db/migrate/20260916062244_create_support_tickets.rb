class CreateSupportTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :support_tickets do |t|
      t.string :reference
      t.string :name
      t.string :email
      t.string :topic
      t.text :message

      t.timestamps
    end
  end
end
