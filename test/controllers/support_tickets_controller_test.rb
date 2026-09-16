require "test_helper"

class SupportTicketsControllerTest < ActionDispatch::IntegrationTest
  def ticket_params(**overrides)
    { support_ticket: { name: "Анна", email: "anna@mail.ru", topic: "Передержка",
                        message: "Питомца некуда деть на выходные, нужна помощь." }.merge(overrides) }
  end

  test "обращение сохраняется и показывается подтверждение" do
    assert_difference -> { SupportTicket.count }, 1 do
      post support_tickets_path, params: ticket_params, as: :turbo_stream
    end

    assert_response :success
    assert_match "принято", response.body
  end

  test "ошибки показываются в форме" do
    assert_no_difference -> { SupportTicket.count } do
      post support_tickets_path, params: ticket_params(message: "Коротко"), as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_match "минимум 20 символов", response.body
    # turbo_stream.update сохраняет #ticket, чтобы повторная отправка тоже нашла цель.
    assert_match %r{<turbo-stream action="update" target="ticket">}, response.body
  end
end
