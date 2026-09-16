require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Perpet
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Сервис русскоязычный: локаль и часовой пояс по умолчанию.
    config.i18n.default_locale = :ru
    config.time_zone = "Moscow"

    # Откуда мини-приложению VK разрешено ходить в /api/v1.
    # Список задаётся через CORS_ORIGINS, «*» внутри домена разрешена.
    default_origins = "https://vk.com,https://m.vk.com,https://*.vk-apps.ru,https://*.vk-apps.com,http://localhost:5173"
    config.x.cors_origins = ENV.fetch("CORS_ORIGINS", default_origins).split(",").map do |origin|
      origin = origin.strip
      origin.include?("*") ? /\A#{Regexp.escape(origin).gsub('\*', ".+")}\z/ : origin
    end
  end
end
