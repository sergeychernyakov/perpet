class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  enum :role, { member: 0, admin: 1 }

  has_one :profile, dependent: :destroy

  after_create :create_default_profile

  def display_name
    profile&.name.presence || email
  end

  private

  # У каждого пользователя сразу есть профиль — его страница доступна после входа.
  def create_default_profile
    create_profile!(name: email.split("@").first, email: email)
  end
end
