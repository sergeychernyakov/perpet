require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "гостя отправляет на вход" do
    get profile_path

    assert_redirected_to new_user_session_path
  end

  test "пользователь видит свой профиль" do
    user = User.create!(email: "anna@mail.ru", password: "perpet123")
    user.profile.update!(name: "Анна Петрова", age: "31 год", city: "Москва", phone: "89031234567")
    sign_in user

    get profile_path

    assert_response :success
    assert_select ".banner__title", "Ваш профиль"
    assert_select ".person__lines span", text: "Имя: Анна Петрова"
    assert_select ".person__lines span", text: "Телефон: 89031234567"
    assert_select ".person__edit[href=?]", edit_profile_path
    assert_select ".profile__account", /anna@mail\.ru/
  end

  test "профиль сохраняется" do
    sign_in_member(email: "anna@mail.ru")

    patch profile_path, params: { profile: { name: "Анна", city: "Казань", about: "Люблю котов" } }

    assert_redirected_to profile_path
    assert_equal "Люблю котов", Profile.last.about
  end

  test "пустое имя не сохраняется" do
    sign_in_member

    patch profile_path, params: { profile: { name: "" } }

    assert_response :unprocessable_entity
  end

  test "без карточек показывается «Упс!»" do
    sign_in_member

    get profile_pets_path

    assert_response :success
    assert_select ".oops__title", "Упс!"
  end

  test "свои карточки видны в списке" do
    user = sign_in_member
    user.profile.ads.create!(kind: "Кот", title: "Мартин", status: "published")

    get profile_pets_path

    assert_select ".ad__title", "Мартин"
    assert_select ".ad__owner", "Изменить"
  end
end
