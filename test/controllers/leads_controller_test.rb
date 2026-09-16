require "test_helper"

class LeadsControllerTest < ActionDispatch::IntegrationTest
  test "заявка сохраняется и показывает подтверждение" do
    assert_difference -> { Lead.count }, 1 do
      post leads_path, params: { lead: { name: "Сергей", email: "sergey@mail.ru", city: "Москва", kind: "join" } },
           as: :turbo_stream
    end

    assert_response :success
    assert_match "Готово", response.body
  end

  test "отклик на объявление запоминает тему" do
    post leads_path, params: { lead: { name: "Сергей", email: "sergey@mail.ru", kind: "respond",
                                       subject: "Барсик, 4 года" } }, as: :turbo_stream

    assert_response :success
    assert_equal "Барсик, 4 года", Lead.last.subject
    assert_match "Отклик отправлен", response.body
  end

  test "неверный e-mail возвращает форму с ошибкой" do
    assert_no_difference -> { Lead.count } do
      post leads_path, params: { lead: { name: "Сергей", email: "sergey", kind: "join" } }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_match "Проверьте e-mail", response.body
  end
end
