require "test_helper"

module Api
  module V1
    class ApiTest < ActionDispatch::IntegrationTest
      setup do
        @ad = Ad.create!(title: "Мурзик, 2 года", kind: "Кот", city: "Москва",
                         period: "1–5 июля", price: "500 ₽ / день", status: "published",
                         published_on: Date.current)
        Ad.create!(title: "Тоша, 3 года", kind: "Собака", city: "Казань", status: "published")
        @article = Article.create!(title: "Как подготовить питомца", tag: "Передержка",
                                   excerpt: "Коротко", body: "Первый абзац.\n\nВторой абзац.", position: 1)
      end

      def json
        JSON.parse(response.body)
      end

      # Без защищённого ключа (dev и тесты) подпись не проверяется — достаточно vk_user_id.
      def vk_headers(user_id = 501)
        { "X-VK-Launch-Params" => "vk_user_id=#{user_id}&vk_app_id=1" }
      end

      test "каталог объявлений отдаётся со страницами" do
        get api_v1_ads_path

        assert_response :success
        assert_equal 2, json["meta"]["total"]
        assert_equal 1, json["meta"]["page"]
        assert_equal "Мурзик, 2 года", json["ads"].first["title"]
      end

      test "каталог фильтруется по виду и поиску" do
        get api_v1_ads_path, params: { kind: "Собака" }
        assert_equal [ "Тоша, 3 года" ], json["ads"].map { |ad| ad["title"] }

        get api_v1_ads_path, params: { q: "москва" }
        assert_equal [ "Мурзик, 2 года" ], json["ads"].map { |ad| ad["title"] }
      end

      test "объявление и статья открываются по id" do
        get api_v1_ad_path(@ad)
        assert_response :success
        assert_equal "Кот", json["ad"]["kind"]

        get api_v1_article_path(@article)
        assert_response :success
        assert_equal [ "Первый абзац.", "Второй абзац." ], json["article"]["paragraphs"]
      end

      test "несуществующая запись отдаёт 404 в json" do
        get api_v1_ad_path(id: 0)

        assert_response :not_found
        assert_equal "Не найдено", json["error"]
      end

      test "без параметров запуска профиль недоступен" do
        get api_v1_profile_path

        assert_response :unauthorized
      end

      test "профиль заводится по vk_user_id и обновляется" do
        assert_difference -> { User.count }, 1 do
          get api_v1_profile_path, headers: vk_headers
        end

        assert_response :success
        assert_equal "vk-501", json["profile"]["name"]
        # Технический адрес в контакты не попадает — он ничей.
        assert_nil json["profile"]["email"]

        patch api_v1_profile_path, headers: vk_headers,
              params: { profile: { name: "Анна", pet_name: "Барсик", pet_age: "3 года" } }

        assert_response :success
        assert_equal "Барсик, 3 года", json["profile"]["pet_caption"]

        # Повторный запрос не плодит пользователей.
        assert_no_difference -> { User.count } do
          get api_v1_profile_path, headers: vk_headers
        end
      end

      test "одновременные запросы не создают двух пользователей VK" do
        # Мини-приложение на первом экране дёргает профиль и «мои объявления» разом.
        assert_difference -> { User.count }, 1 do
          2.times { User.for_vk("777") }
        end

        # Проигравший гонку запрос получает уже созданного пользователя, а не ошибку:
        # его find_by ещё не видит записи, а create! упирается в уникальный индекс.
        expected = User.find_by!(vk_id: "777")
        original = User.method(:find_by)
        calls = 0
        User.define_singleton_method(:find_by) do |*args, **options|
          calls += 1
          calls == 1 ? nil : original.call(*args, **options)
        end

        begin
          assert_equal expected, User.for_vk("777")
        ensure
          User.singleton_class.send(:remove_method, :find_by)
        end
      end

      test "пустое имя профиля не сохраняется" do
        patch api_v1_profile_path, headers: vk_headers, params: { profile: { name: "" } }

        assert_response :unprocessable_entity
        assert_includes json["errors"], "Укажите имя"
      end

      test "объявление создаётся черновиком и попадает в мои" do
        assert_difference -> { Ad.count }, 1 do
          post api_v1_ads_path, headers: vk_headers, params: { ad: { title: "Кеша", kind: "Птица" } }
        end

        assert_response :created
        assert_equal "draft", json["ad"]["status"]

        get mine_api_v1_ads_path, headers: vk_headers
        assert_equal [ "Кеша" ], json["ads"].map { |ad| ad["title"] }
      end

      test "объявление создаётся с фотографией" do
  pixel = Rack::Test::UploadedFile.new(
    StringIO.new(Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==")),
    "image/png", original_filename: "pet.png"
  )

  post api_v1_ads_path, headers: vk_headers,
       params: { ad: { title: "Кеша", kind: "Птица", photo: pixel } }

  assert_response :created
  assert_match %r{\A/rails/active_storage/}, json["ad"]["photo_url"]
  assert Ad.last.photo.attached?
end

test "чужое объявление не редактируется" do
        patch api_v1_ad_path(@ad), headers: vk_headers, params: { ad: { title: "Взлом" } }

        assert_response :not_found
        assert_equal "Мурзик, 2 года", @ad.reload.title
      end

      test "заявка и обращение принимаются из мини-приложения" do
        assert_difference -> { Lead.count }, 1 do
          post api_v1_leads_path, params: { lead: { name: "Анна", email: "anna@mail.ru", kind: "respond",
                                                    subject: "Мурзик, 2 года" } }
        end
        assert_response :created

        assert_difference -> { SupportTicket.count }, 1 do
          post api_v1_support_tickets_path,
               params: { support_ticket: { name: "Анна", email: "anna@mail.ru", topic: "Оплата",
                                           message: "Не понимаю, как оплатить передержку питомца." } }
        end
        assert_response :created
        assert_match(/\A#\d+\z/, json["reference"])
      end

      test "заявка с плохой почтой возвращает ошибки" do
        post api_v1_leads_path, params: { lead: { name: "Анна", email: "anna", kind: "join" } }

        assert_response :unprocessable_entity
        assert_includes json["errors"].join(" "), "Проверьте e-mail"
      end

      test "справочник поддержки отдаёт каналы, вопросы и темы" do
        SupportChannel.create!(title: "Телефон", value: "+7 963 574-79-20", position: 1)
        FaqItem.create!(question: "Как это работает?", answer: "Просто.", position: 1)

        get api_v1_support_path

        assert_response :success
        assert_equal "Телефон", json["channels"].first["title"]
        assert_equal "Как это работает?", json["faq"].first["question"]
        assert_equal SupportTicket::TOPICS, json["topics"]
      end
    end
  end
end
