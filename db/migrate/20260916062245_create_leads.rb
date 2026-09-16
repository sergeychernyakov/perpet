class CreateLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :leads do |t|
      t.string :name
      t.string :email
      t.string :city
      t.string :subject
      t.string :kind

      t.timestamps
    end
  end
end
