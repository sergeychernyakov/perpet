require "test_helper"

class VkAuthControllerTest < ActionDispatch::IntegrationTest
  PERSON = VkId::Person.new(vk_id: "777", email: "sergey@vk.example",
                            first_name: "Сергей", last_name: "Черняков", city: "Москва")

  setup do
    ENV["VK_ID_ENABLED"] = "1"
    ENV["VK_APP_ID"] = "54774841"
    ENV["VK_APP_SECRET"] = "секретсекретсекрет01"
  end

  teardown do
    ENV.delete("VK_ID_ENABLED")
    ENV.delete("VK_APP_ID")
    ENV.delete("VK_APP_SECRET")
  end

  # Сеть в тестах не трогаем: подменяем единственный метод, который туда ходит.
  def with_vk_person(person = PERSON)
    original = VkId.method(:person)
    VkId.define_singleton_method(:person) { |**| person }
    yield
  ensure
    VkId.singleton_class.send(:remove_method, :person)
    VkId.define_singleton_method(:person, original) if VkId.singleton_methods.exclude?(:person)
  end

  # Возвращает state, который контроллер положил в сессию.
  def start_and_state
    get auth_vk_path
    assert_response :redirect
    assert_match %r{\Ahttps://id\.vk\.com/authorize\?}, response.location

    query = Rack::Utils.parse_query(URI(response.location).query)
    assert_equal "54774841", query["client_id"]
    assert_equal "s256", query["code_challenge_method"]
    assert query["code_challenge"].present?

    query["state"]
  end

  test "без ключей вход через ВКонтакте не предлагается" do
    ENV.delete("VK_APP_SECRET")

    get auth_vk_path

    assert_redirected_to new_user_session_path
    assert_equal "Вход через ВКонтакте не настроен", flash[:alert]
  end

  test "снятый выключатель прячет вход через ВКонтакте" do
    ENV.delete("VK_ID_ENABLED")

    assert_not VkId.configured?, "ключи есть, но выключатель снят"

    get auth_vk_path
    assert_redirected_to new_user_session_path

    get new_user_session_path
    assert_select ".btn--vk", false, "кнопки ВКонтакте на странице входа быть не должно"
  end

  test "новый человек заходит через ВКонтакте" do
    state = start_and_state

    assert_difference -> { User.count }, 1 do
      with_vk_person { get auth_vk_callback_path(code: "код", state: state, device_id: "устройство") }
    end

    assert_redirected_to profile_path
    user = User.last
    assert_equal "777", user.vk_id
    assert_equal "sergey@vk.example", user.email
    assert_equal "Сергей Черняков", user.profile.name
    assert_equal "Москва", user.profile.city
  end

  test "тот же человек из мини-приложения узнаётся по vk_id" do
    existing = User.for_vk("777")
    assert existing.technical_email?

    state = start_and_state

    assert_no_difference -> { User.count } do
      with_vk_person { get auth_vk_callback_path(code: "код", state: state, device_id: "устройство") }
    end

    existing.reload
    # Технический адрес заменяется настоящим, аккаунт и профиль — те же.
    assert_equal "sergey@vk.example", existing.email
    assert_equal existing.profile.id, User.last.profile.id
  end

  test "вошедший по почте привязывает страницу ВКонтакте" do
    user = sign_in_member(email: "anna@mail.ru")
    state = start_and_state

    with_vk_person { get auth_vk_callback_path(code: "код", state: state, device_id: "устройство") }

    assert_redirected_to profile_path
    assert_equal "ВКонтакте привязан", flash[:notice]
    assert_equal "777", user.reload.vk_id
    # Свою почту не трогаем — человек её выбрал сам.
    assert_equal "anna@mail.ru", user.email
  end

  test "чужая страница ВКонтакте к аккаунту не привязывается" do
    User.for_vk("777")
    user = sign_in_member(email: "other@mail.ru")
    state = start_and_state

    with_vk_person { get auth_vk_callback_path(code: "код", state: state, device_id: "устройство") }

    assert_equal "Эта страница ВКонтакте уже привязана к другому аккаунту", flash[:alert]
    assert_nil user.reload.vk_id
  end

  test "подменённый state отклоняется" do
    start_and_state

    assert_no_difference -> { User.count } do
      with_vk_person { get auth_vk_callback_path(code: "код", state: "чужой", device_id: "устройство") }
    end

    assert_equal "Не удалось проверить ответ ВКонтакте", flash[:alert]
  end

  test "отказ во ВКонтакте не ломает сайт" do
    state = start_and_state

    get auth_vk_callback_path(state: state, error: "access_denied")

    assert_redirected_to new_user_session_path
    assert_equal "Вход через ВКонтакте отменён", flash[:alert]
  end
end
