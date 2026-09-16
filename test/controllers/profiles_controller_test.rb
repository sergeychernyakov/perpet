require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "гостя отправляет на вход" do
    get profile_path

    assert_redirected_to new_user_session_path
  end

  test "пользователь видит свой профиль" do
    user = User.create!(email: "anna@mail.ru", password: "perpet123")
    user.profile.update!(name: "Анна Петрова", pet_name: "Барсик", pet_age: "4 года")
    sign_in user

    get profile_path

    assert_response :success
    assert_select ".profile__caption", "Барсик, 4 года"
    assert_select ".profile__account", /anna@mail\.ru/
  end

  test "профиль сохраняется" do
    sign_in_member(email: "anna@mail.ru")

    patch profile_path, params: { profile: { name: "Анна", city: "Казань", email: "anna@mail.ru" } }

    assert_redirected_to profile_path
    assert_equal "Казань", Profile.last.city
  end

  test "пустое имя не сохраняется" do
    sign_in_member

    patch profile_path, params: { profile: { name: "" } }

    assert_response :unprocessable_entity
  end
end
