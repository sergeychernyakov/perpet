class Lead < ApplicationRecord
  KINDS = %w[join respond].freeze

  validates :name, presence: { message: "Укажите имя" }, length: { minimum: 2, message: "Укажите имя" }
  validates :email, format: { with: SupportTicket::EMAIL, message: "Проверьте e-mail" }
  validates :kind, inclusion: { in: KINDS }

  def respond?
    kind == "respond"
  end

  def success_text
    if respond?
      "Отклик отправлен — хозяин получит ваши контакты."
    else
      "Заявка отправлена. Мы свяжемся с вами по указанному контакту."
    end
  end
end
