class SupportTicket < ApplicationRecord
  TOPICS = [ "Передержка", "Объявление", "Оплата", "Документы", "Другое" ].freeze
  EMAIL = /\A[^@\s]+@[^@\s]+\.[a-zа-я]{2,}\z/i

  validates :name, presence: { message: "Укажите имя" }, length: { minimum: 2, message: "Укажите имя" }
  validates :email, format: { with: EMAIL, message: "Проверьте e-mail" }
  validates :message, length: { minimum: 20, message: "Опишите ситуацию подробнее — минимум 20 символов" }
  validates :topic, inclusion: { in: TOPICS }

  before_validation :assign_reference, on: :create

  private

  def assign_reference
    self.reference ||= "##{rand(1200..1999)}"
  end
end
