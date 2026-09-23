require "test_helper"

class PublicProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @profile = User.create!(email: "mixi@mail.ru", password: "perpet123").profile
    @profile.update!(name: "Михаил", age: "27", city: "г. Москва", activity: "Работа",
                     phone: "89059382319", email: "mixi@mail.ru", about: "Хозяин нескольких питомцев.")
  end

  test "карточка пользователя показывает данные и его объявления" do
    Ad.create!(profile: @profile, kind: "Кот", title: "Мартин", status: "published")

    get public_profile_path(@profile)

    assert_response :success
    assert_select ".banner__title", "Карточка пользователя"
    assert_select ".person__lines span", text: "Имя: Михаил"
    assert_select ".person__lines span", text: "Телефон: 89059382319"
    assert_select ".ad__title", "Мартин"
  end

  test "профиль без опубликованных объявлений не открывается" do
    get public_profile_path(@profile)

    assert_response :not_found
  end
end
