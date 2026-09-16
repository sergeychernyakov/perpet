require "application_system_test_case"

class SupportTest < ApplicationSystemTestCase
  test "обращение: счётчик символов, ошибка и повторная отправка" do
    visit support_path

    fill_in "support_ticket[name]", with: "Анна"
    fill_in "support_ticket[message]", with: "Коротко"
    assert_text "Ещё 13 символов"

    fill_in "support_ticket[message]", with: "Питомца некуда деть на выходные, помогите с передержкой."
    assert_text "56 символов"

    # Такой адрес браузер пропускает, а серверная проверка — нет.
    fill_in "support_ticket[email]", with: "anna@mail"
    click_on "Отправить обращение"

    assert_text "Проверьте e-mail"
    # Введённое не должно пропасть вместе с перерисовкой формы.
    assert_field "support_ticket[message]", with: /Питомца некуда деть/
    assert_field "support_ticket[name]", with: "Анна"

    assert_difference -> { SupportTicket.count }, 1 do
      fill_in "support_ticket[email]", with: "anna@mail.ru"
      click_on "Отправить обращение"
      assert_text "принято"
    end

    assert_text "Ответ придёт на anna@mail.ru"
  end

  test "меню на телефоне открывается и ведёт на вход" do
    resize_to_phone
    visit root_path

    assert_no_selector ".nav", visible: true
    find(".burger").click

    within ".menu" do
      click_on "Войти"
    end

    assert_current_path new_user_session_path
  end

  private

  def resize_to_phone
    page.driver.browser.manage.window.resize_to(390, 844)
  end
end
