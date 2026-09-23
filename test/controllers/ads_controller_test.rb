require "test_helper"

class AdsControllerTest < ActionDispatch::IntegrationTest
  setup do
    7.times do |i|
      Ad.create!(kind: i.even? ? "Кот" : "Собака", title: "Питомец #{i}", city: "Москва",
                 period: "1–10 июля", price: "700 ₽ / день", description: "Описание #{i}",
                 status: "published", published_on: Date.current - i)
    end
  end

  test "каталог показывает первую страницу" do
    get ads_path

    assert_response :success
    assert_select ".ad", Paginator::PER_PAGE
    assert_select ".pager"
  end

  test "фильтр по виду питомца" do
    get ads_path(kind: "Собака")

    assert_response :success
    assert_select ".ad", 3
  end

  test "раздел ситтеров показывает только их карточки" do
    Ad.create!(role: Ad::SITTER, title: "Пётр", city: "Москва", age: "32 года",
               activity: "Работа", description: "Работаю онлайн.", status: "published")

    get ads_path(role: Ad::SITTER)

    assert_response :success
    assert_select ".ad", 1
    assert_select ".ad__title", "Пётр"
    assert_select ".ads__tab--current", "Обьявления ситтеров"
  end

  test "поиск без результатов показывает пустое состояние" do
    get ads_path(q: "хамелеон")

    assert_response :success
    assert_select ".empty__title", "Ничего не нашлось"
  end

  test "с карточки есть ссылка на хозяина" do
    profile = User.create!(email: "mixi@mail.ru", password: "perpet123").profile
    profile.update!(name: "Михаил")
    Ad.create!(profile: profile, kind: "Кот", title: "Мартин", status: "published",
               published_on: Date.current + 1)

    get ads_path

    assert_select ".ad__owner[href=?]", public_profile_path(profile), text: "Хозяин"
  end

  test "гость не может завести карточку" do
    assert_no_difference -> { Ad.count } do
      post ads_path, params: { ad: { title: "Мартин", kind: "Кот" } }
    end

    assert_redirected_to new_user_session_path
  end

  test "пользователь заводит карточку питомца" do
    user = User.create!(email: "anna@mail.ru", password: "perpet123")
    sign_in user

    assert_difference -> { user.profile.ads.count }, 1 do
      post ads_path, params: { ad: { role: Ad::PET, title: "Мартин", kind: "Кот",
                                     age: "3 года", city: "г. Москва" } }
    end

    assert_redirected_to profile_pets_path
    assert_equal "published", user.profile.ads.last.status
  end

  test "форма карточки ситтера заполнена данными профиля" do
    user = sign_in_member
    user.profile.update!(name: "Мария", age: "23", activity: "Обучение", about: "Люблю котов")

    get new_ad_path(role: Ad::SITTER)

    assert_response :success
    assert_select ".banner__title", "Карточка временного хозяина"
    assert_select "input[value=?]", "Мария"
  end

  test "чужую карточку не отредактировать" do
    other = User.create!(email: "other@mail.ru", password: "perpet123").profile
    ad = Ad.create!(profile: other, kind: "Кот", title: "Мартин", status: "published")
    sign_in_member

    get edit_ad_path(ad)

    assert_response :not_found
  end
end
