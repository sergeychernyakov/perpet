# Мини-приложение VK живёт на своём домене (*.vk-apps.com) и ходит в /api/v1
# из браузера, поэтому нужны заголовки CORS. Список источников задаётся
# переменной окружения CORS_ORIGINS через запятую.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*Rails.application.config.x.cors_origins)

    resource "/api/*",
             headers: :any,
             methods: %i[get post patch put delete options head],
             expose: %w[X-Request-Id],
             max_age: 600
  end
end
