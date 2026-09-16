require "test_helper"

class AdsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @profile = Profile.create!(name: "Анна Петрова", city: "Москва", email: "anna@mail.ru")
    7.times do |i|
      Ad.create!(kind: i.even? ? "Кошка" : "Собака", title: "Питомец #{i}", city: "Москва",
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

  test "поиск без результатов показывает пустое состояние" do
    get ads_path(q: "хамелеон")

    assert_response :success
    assert_select ".empty__title", "Ничего не нашлось"
  end

  test "создание черновика из профиля" do
    assert_difference -> { @profile.ads.count }, 1 do
      post ads_path
    end

    assert_redirected_to profile_path
    assert_equal "draft", @profile.ads.last.status
  end
end
