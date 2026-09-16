class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  enum :role, { member: 0, admin: 1 }

  has_one :profile, dependent: :destroy

  after_create :create_default_profile

  # Посетитель мини-приложения VK: логина и пароля у него нет, поэтому заводим
  # техническую учётную запись, привязанную к vk_user_id.
  def self.for_vk(vk_id)
    find_by(vk_id: vk_id) || create!(
      vk_id: vk_id,
      email: "vk-#{vk_id}@vk.perpet.local",
      password: Devise.friendly_token(24)
    )
  end

  def display_name
    profile&.name.presence || email
  end

  private

  # У каждого пользователя сразу есть профиль — его страница доступна после входа.
  def create_default_profile
    create_profile!(name: email.split("@").first, email: email)
  end
end
