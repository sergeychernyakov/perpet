# Параметры запуска мини-приложения VK.
#
# VK передаёт их в query string при открытии приложения, а мини-приложение
# пересылает строку дальше в API. Подпись считается так: берём параметры,
# начинающиеся с «vk_», сортируем по ключу, склеиваем в query string и
# подписываем HMAC-SHA256 защищённым ключом приложения. Результат — base64url
# без «=» на конце — должен совпасть с параметром sign.
#
# https://dev.vk.com/ru/mini-apps/development/launch-params
class VkLaunchParams
  # Дольше суток подпись не принимаем — параметры запуска протухают.
  MAX_AGE = 24.hours

  attr_reader :params

  def self.secret
    ENV["VK_APP_SECRET"].presence
  end

  # Без защищённого ключа проверять нечего: в dev и в тестах пускаем всех,
  # в production — никого.
  def self.open_access?
    secret.nil? && !Rails.env.production?
  end

  def initialize(query)
    @params = Rack::Utils.parse_nested_query(query.to_s)
  end

  def user_id
    params["vk_user_id"].presence
  end

  def valid?
    return false if user_id.blank?
    return true if self.class.open_access?

    fresh? && signature_matches?
  end

  private

  def fresh?
    timestamp = params["vk_ts"].presence
    return true if timestamp.blank?

    Time.at(timestamp.to_i) > MAX_AGE.ago
  end

  def signature_matches?
    given = params["sign"].to_s
    return false if given.blank?

    ActiveSupport::SecurityUtils.secure_compare(given, expected_signature)
  end

  def expected_signature
    payload = params.select { |key, _| key.start_with?("vk_") }.sort.to_h
    digest = OpenSSL::HMAC.digest("SHA256", self.class.secret, payload.to_query)
    Base64.urlsafe_encode64(digest).delete("=")
  end
end
