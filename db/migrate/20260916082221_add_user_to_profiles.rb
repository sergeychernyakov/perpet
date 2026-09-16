class AddUserToProfiles < ActiveRecord::Migration[8.1]
  def change
    # Профили пересоздаются сидами вместе с пользователями: отвязываем объявления и чистим таблицу.
    if table_exists?(:profiles)
      execute "UPDATE ads SET profile_id = NULL"
      execute "DELETE FROM profiles"
    end

    add_reference :profiles, :user, null: false, foreign_key: true, index: { unique: true }
  end
end
