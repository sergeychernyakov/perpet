require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 900 ]

  include Devise::Test::IntegrationHelpers

  # Turbo подменяет страницу асинхронно, а тесты идут в десять процессов —
  # двух секунд ожидания под нагрузкой иногда не хватает.
  Capybara.default_max_wait_time = 5

  # Пока едут веб-шрифты и отыгрывают анимации появления, блоки на странице
  # переезжают, и клик успевает промахнуться мимо кнопки. Шрифты ждём,
  # анимации глушим — проверяем содержимое, а не эффекты.
  CALM = <<~JS.freeze
    const s = document.createElement('style');
    s.textContent = '*,*::before,*::after{animation:none !important;transition:none !important}';
    document.head.appendChild(s);
    return document.fonts.status === 'loaded';
  JS

  def visit(*)
    super
    Timeout.timeout(5) { sleep 0.05 until page.evaluate_script(CALM) }
  rescue Timeout::Error, Selenium::WebDriver::Error::JavascriptError
    nil
  end
end
