# Вход через ВКонтакте на самом сайте — VK ID, протокол OAuth 2.1 с PKCE.
#
# Гема не берём: весь обмен — три запроса, зато видно, что именно уходит
# в сеть и что возвращается.
#
# https://id.vk.com/about/business/go/docs/ru/vkid/latest/vk-id/connection/start-integration/auth-without-sdk-web
class VkId
  AUTHORIZE_URL = "https://id.vk.com/authorize".freeze
  TOKEN_URL = "https://id.vk.com/oauth2/auth".freeze
  USER_INFO_URL = "https://id.vk.com/oauth2/user_info".freeze

  # Почта нужна, чтобы у человека на сайте был настоящий контакт, а не
  # технический адрес вида vk-<id>@vk.perpet.local.
  SCOPE = "email".freeze

  Error = Class.new(StandardError)

  Person = Data.define(:vk_id, :email, :first_name, :last_name, :city) do
    def full_name
      [ first_name, last_name ].compact_blank.join(" ")
    end
  end

  class << self
    def app_id
      ENV["VK_APP_ID"].presence
    end

    # Ключей может быть несколько (переезд между приложениями) — для VK ID
    # нужен тот, что соответствует app_id, то есть первый в списке.
    def secret
      VkLaunchParams.secrets.first
    end

    def configured?
      app_id.present? && secret.present?
    end

    def verifier
      SecureRandom.urlsafe_base64(64)
    end

    def challenge_for(verifier)
      Base64.urlsafe_encode64(OpenSSL::Digest::SHA256.digest(verifier)).delete("=")
    end

    def authorize_url(redirect_uri:, state:, verifier:)
      params = {
        response_type: "code",
        client_id: app_id,
        redirect_uri: redirect_uri,
        state: state,
        code_challenge: challenge_for(verifier),
        code_challenge_method: "s256",
        scope: SCOPE
      }

      "#{AUTHORIZE_URL}?#{params.to_query}"
    end

    # Меняем одноразовый код на токен, а токен — на данные человека.
    def person(code:, device_id:, verifier:, redirect_uri:)
      token = post(TOKEN_URL, {
        grant_type: "authorization_code",
        code: code,
        code_verifier: verifier,
        client_id: app_id,
        device_id: device_id,
        redirect_uri: redirect_uri
      })

      raise Error, token["error_description"] || token["error"] if token["access_token"].blank?

      info = post(USER_INFO_URL, { access_token: token["access_token"], client_id: app_id })
      user = info["user"] or raise Error, info["error_description"] || "ВКонтакте не вернул данные"

      Person.new(
        vk_id: user["user_id"].to_s,
        email: user["email"].presence,
        first_name: user["first_name"],
        last_name: user["last_name"],
        city: user.dig("city", "title")
      )
    end

    private

    def post(url, params)
      response = Net::HTTP.post_form(URI(url), params.merge(client_secret: secret))

      JSON.parse(response.body)
    rescue JSON::ParserError, SystemCallError, Net::OpenTimeout, Net::ReadTimeout => e
      raise Error, "ВКонтакте не ответил: #{e.class}"
    end
  end
end
