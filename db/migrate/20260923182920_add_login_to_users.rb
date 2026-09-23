# В макете 2.0 вход идёт по логину, а почта остаётся для восстановления пароля.
# Существующим учётным записям логин делаем из адреса: до «собаки».
class AddLoginToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :login, :string

    taken = []
    User.reset_column_information
    User.order(:id).each do |user|
      base = user.email.to_s.split("@").first.to_s.parameterize(separator: "_").presence || "user"
      login = base
      login = "#{base}#{SecureRandom.hex(2)}" while taken.include?(login)
      taken << login
      user.update_columns(login: login)
    end

    add_index :users, :login, unique: true
  end

  def down
    remove_index :users, :login
    remove_column :users, :login
  end
end
