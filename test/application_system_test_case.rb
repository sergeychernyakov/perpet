require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 900 ]

  include Devise::Test::IntegrationHelpers

  # Пока едут веб-шрифты и отыгрывают анимации появления, блоки на странице
  # ещё переезжают, и клик успевает промахнуться мимо кнопки. Ждём и то и другое.
  # Анимации по прокрутке ждать нельзя — они не заканчиваются никогда.
  SETTLED = <<~JS.freeze
    return document.fonts.status === 'loaded' &&
      document.getAnimations().every(a =>
        !(a.timeline instanceof DocumentTimeline) || a.playState !== 'running');
  JS

  def visit(*)
    super
    Timeout.timeout(5) { sleep 0.05 until page.evaluate_script(SETTLED) }
  rescue Timeout::Error, Selenium::WebDriver::Error::JavascriptError
    nil
  end
end
