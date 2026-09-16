require "test_helper"

class SupportTicketTest < ActiveSupport::TestCase
  def build(**attributes)
    SupportTicket.new({ name: "Анна", email: "anna@mail.ru", topic: "Передержка",
                        message: "Питомца некуда деть на выходные, нужна помощь." }.merge(attributes))
  end

  test "корректное обращение сохраняется и получает номер" do
    ticket = build
    assert ticket.save
    assert_match(/\A#\d{4}\z/, ticket.reference)
  end

  test "короткое имя не проходит" do
    ticket = build(name: "А")
    assert_not ticket.valid?
    assert_equal "Укажите имя", ticket.errors.first.message
  end

  test "e-mail проверяется" do
    ticket = build(email: "anna@mail")
    assert_not ticket.valid?
    assert_equal "Проверьте e-mail", ticket.errors.first.message
  end

  test "сообщение короче 20 символов не проходит" do
    ticket = build(message: "Помогите")
    assert_not ticket.valid?
    assert_equal "Опишите ситуацию подробнее — минимум 20 символов", ticket.errors.first.message
  end
end
