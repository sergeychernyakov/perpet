class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  enum :role, { member: 0, admin: 1 }

  has_one :profile, dependent: :destroy

  after_create :create_default_profile

  # Посетитель мини-приложения VK: логина и пароля у него нет, поэтому заводим
  # техническую учётную запись, привязанную к vk_user_id.
  #
  # Мини-приложение открывает несколько запросов сразу, и на первом запуске
  # они пытаются создать пользователя одновременно. Уникальные индексы на
  # vk_id и email это ловят — проигравшему запросу просто отдаём уже созданного.
  def self.for_vk(vk_id)
    find_by(vk_id: vk_id) || create!(
      vk_id: vk_id,
      email: "vk-#{vk_id}@vk.perpet.local",
      password: Devise.friendly_token(24)
    )
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    find_by!(vk_id: vk_id)
  end

  # Вход через VK ID на сайте. Тот же человек, что заходил в мини-приложение,
  # узнаётся по vk_id — аккаунт, профиль и объявления у него общие.
  def self.from_vk_id(person)
    user = find_by(vk_id: person.vk_id) || find_by(email: person.email.to_s.downcase.presence)
    return create_from_vk_id(person) if user.nil?

    user.vk_id = person.vk_id
    # Технический адрес меняем на настоящий, если ВКонтакте его дал.
    user.email = person.email if person.email.present? && user.technical_email?
    user.save(validate: false) if user.changed?

    user
  end

  def self.create_from_vk_id(person)
    user = create!(
      vk_id: person.vk_id,
      email: person.email.presence || "vk-#{person.vk_id}@vk.perpet.local",
      password: Devise.friendly_token(24)
    )

    # Имя по умолчанию берётся из адреса почты — у пришедшего из VK оно заведомо
    # хуже настоящего, так что сразу заменяем.
    user.profile.update(name: person.full_name) if person.full_name.present?

    user
  end
  private_class_method :create_from_vk_id

  # Адрес, который мы придумали сами, когда VK его не дал.
  def technical_email?
    email.to_s.end_with?("@vk.perpet.local")
  end

  def display_name
    profile&.name.presence || email
  end

  private

  # У каждого пользователя сразу есть профиль — его страница доступна после входа.
  # Гостю из VK технический адрес в контакты не пишем: он ничей и писать на него
  # некуда, пусть человек укажет свой.
  def create_default_profile
    create_profile!(name: email.split("@").first, email: vk_id? ? nil : email)
  end
end
