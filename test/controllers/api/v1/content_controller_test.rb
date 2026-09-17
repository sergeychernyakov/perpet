require "test_helper"

module Api
  module V1
    class ContentControllerTest < ActionDispatch::IntegrationTest
      # Без защищённого ключа (dev и тесты) подпись не проверяется.
      LAUNCH = { "X-VK-Launch-Params" => "vk_user_id=501&vk_app_id=1" }.freeze

      test "мини-приложение получает оформление главной" do
        get api_v1_content_path, headers: LAUNCH

        assert_response :success
        body = response.parsed_body

        assert_equal Advantage.all.size, body["advantages"].size
        assert_equal Advantage.all.first.text, body["advantages"].first["text"]
        assert_match %r{/assets/.+\.svg}, body["advantages"].first["icon"]

        assert_equal Promo.all.size, body["promos"].size
        assert_equal "articles", body["promos"].first["route"]

        assert_equal Brand::SWATCHES, body["brand"]["swatches"]
        assert_equal Brand.values.size, body["brand"]["values"].size
      end

      # Оформление — не пользовательские данные, поэтому отдаётся без входа,
      # как каталог, статьи и страница поддержки.
      test "оформление доступно без параметров запуска VK" do
        get api_v1_content_path

        assert_response :success
        assert response.parsed_body["promos"].any?
      end
    end
  end
end
