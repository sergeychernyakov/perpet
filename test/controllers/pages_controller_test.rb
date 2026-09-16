require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "главная открывается" do
    get root_path

    assert_response :success
    assert_select "h1", "PERPET"
    assert_select ".promo", 3
  end

  test "страница о сервисе открывается" do
    get about_path

    assert_response :success
    assert_select "h1", "Знакомство с нами"
    assert_select ".step", 3
  end
end
