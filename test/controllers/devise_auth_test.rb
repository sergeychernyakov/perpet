require "test_helper"

class DeviseAuthTest < ActionDispatch::IntegrationTest
  test "регистрация заводит аккаунт с логином и именем в профиле" do
    assert_difference -> { User.count }, 1 do
      post user_registration_path, params: { user: {
        name: "Мария", email: "m.mary@mail.ru", login: "Maria", password: "perpet123"
      } }
    end

    user = User.last
    assert_equal "maria", user.login
    assert_equal "Мария", user.profile.name
    assert_redirected_to root_path
  end

  test "вход идёт по логину, а не по почте" do
    User.create!(login: "maria", email: "m.mary@mail.ru", password: "perpet123")

    post user_session_path, params: { user: { login: "maria", password: "perpet123" } }
    assert_redirected_to root_path

    delete destroy_user_session_path

    post user_session_path, params: { user: { login: "m.mary@mail.ru", password: "perpet123" } }
    assert_response :unprocessable_entity
  end

  test "логин занят — регистрация не проходит" do
    User.create!(login: "maria", email: "one@mail.ru", password: "perpet123")

    assert_no_difference -> { User.count } do
      post user_registration_path, params: { user: {
        name: "Мария", email: "two@mail.ru", login: "maria", password: "perpet123"
      } }
    end

    assert_response :unprocessable_entity
  end

  test "на форме входа поле логина и ссылка на регистрацию" do
    get new_user_session_path

    assert_response :success
    assert_select ".reg__title", "Вход"
    assert_select "input[name=?]", "user[login]"
    assert_select ".reg__switch-btn[href=?]", new_user_registration_path, text: "Присоединиться"
  end

  test "гостю из VK логин придумываем сами" do
    user = User.for_vk("849231532")

    assert_equal "vk-849231532", user.login
  end
end
