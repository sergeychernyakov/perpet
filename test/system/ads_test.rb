require "application_system_test_case"

# Окно отклика живёт на Turbo Stream и Stimulus — ошибки в нём не видны
# обычным тестам контроллера, поэтому проверяем его в настоящем браузере.
class AdsTest < ApplicationSystemTestCase
  setup do
    @ad = Ad.create!(title: "Мурзик, 2 года", kind: "Кот", city: "Москва",
                     period: "1–5 июля", price: "500 ₽ / день",
                     description: "Спокойный кот", status: "published",
                     published_on: Date.current)
  end

  test "отклик на объявление: ошибка, повторная отправка, сброс при переоткрытии" do
    visit ads_path

    within ".ad" do
      click_on "Откликнуться"
    end

    assert_text "Отклик на объявление"
    assert_text "Вы откликаетесь: #{@ad.title}"

    # «anna@mail» браузер считает валидным адресом, а сервер — нет:
    # так проверяем именно серверную валидацию и перерисовку формы.
    fill_in "lead[name]", with: "Анна"
    fill_in "lead[email]", with: "anna@mail"
    click_on "Отправить"

    assert_text "Проверьте e-mail"
    # Заголовок и тема не должны потеряться вместе с перерисовкой формы.
    assert_text "Вы откликаетесь: #{@ad.title}"
    assert_field "lead[name]", with: "Анна"

    # Повторная отправка обязана дойти: раньше обёртка окна исчезала после ошибки.
    assert_difference -> { Lead.count }, 1 do
      fill_in "lead[email]", with: "anna@mail.ru"
      click_on "Отправить"
      assert_text "Отклик отправлен"
    end

    assert_equal @ad.title, Lead.last.subject

    within "#modal-body" do
      click_on "Закрыть"
    end

    within ".ad" do
      click_on "Откликнуться"
    end

    assert_field "lead[name]", with: ""
  end

  test "фильтр, поиск и пустая выдача" do
    Ad.create!(title: "Тоша, 3 года", kind: "Собака", city: "Казань", status: "published")

    visit ads_path
    assert_text "Найдено: 2 из 2"

    click_on "Собака"
    assert_text "Найдено: 1 из 2"
    assert_text "Тоша, 3 года"
    assert_no_text "Мурзик"

    click_on "Все"
    fill_in "q", with: "казань"
    click_on "Найти"
    assert_text "Найдено: 1 из 2"
    assert_text "Тоша, 3 года"

    fill_in "q", with: "такого нет"
    click_on "Найти"
    assert_text "Ничего не нашлось"
  end
end
