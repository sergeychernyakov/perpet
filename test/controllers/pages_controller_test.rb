require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "главная открывается" do
    get root_path

    assert_response :success
    assert_select "h1", "PERPET"
    assert_select ".promo", 3
  end

  test "гостю кнопка в шапке ведёт на вход" do
    get root_path

    assert_select ".icon-btn[href=?]", new_user_session_path
    assert_select ".nav__link", { text: "Админка", count: 0 }, "гость не должен видеть админку"
  end

  test "администратор видит ссылку на админку в шапке" do
    sign_in_admin

    get root_path

    assert_select ".nav__link[href=?]", admin_root_path, text: "Админка"
    assert_select ".icon-btn[href=?]", profile_path
  end

  test "обычный пользователь ссылки на админку не видит" do
    sign_in_member

    get root_path

    assert_select ".nav__link", { text: "Админка", count: 0 }
    assert_select ".menu__link", { text: "Админка", count: 0 }
  end

  test "страница о сервисе открывается" do
    get about_path

    assert_response :success
    assert_select "h1", "Знакомство с нами"
    assert_select ".step", 3
  end
end
