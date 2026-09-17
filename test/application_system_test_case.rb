require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 900 ]

  include Devise::Test::IntegrationHelpers

  # Заголовки набраны веб-шрифтами: пока они едут, блоки на странице ещё
  # переезжают, и клик успевает промахнуться мимо кнопки. Ждём загрузки.
  def visit(*)
    super
    Timeout.timeout(5) do
      sleep 0.05 until page.evaluate_script("document.fonts.status") == "loaded"
    end
  rescue Timeout::Error, Selenium::WebDriver::Error::JavascriptError
    nil
  end
end
