require "test_helper"

class VkLaunchParamsTest < ActiveSupport::TestCase
  SECRET = "wvl0LCaMnkmML4mkkZ61"

  def sign(params)
    payload = params.select { |key, _| key.to_s.start_with?("vk_") }.sort.to_h
    digest = OpenSSL::HMAC.digest("SHA256", SECRET, payload.to_query)
    Base64.urlsafe_encode64(digest).delete("=")
  end

  def with_secret
    ENV["VK_APP_SECRET"] = SECRET
    yield
  ensure
    ENV.delete("VK_APP_SECRET")
  end

  test "без защищённого ключа вне production достаточно vk_user_id" do
    assert VkLaunchParams.new("vk_user_id=42").valid?
    assert_not VkLaunchParams.new("vk_app_id=1").valid?
  end

  test "верная подпись принимается" do
    params = { "vk_user_id" => "42", "vk_app_id" => "7", "vk_ts" => Time.current.to_i.to_s }

    with_secret do
      query = params.merge("sign" => sign(params)).to_query

      assert VkLaunchParams.new(query).valid?
      assert_equal "42", VkLaunchParams.new(query).user_id
    end
  end

  test "подделанные параметры отклоняются" do
    params = { "vk_user_id" => "42", "vk_app_id" => "7" }

    with_secret do
      forged = params.merge("vk_user_id" => "43", "sign" => sign(params)).to_query

      assert_not VkLaunchParams.new(forged).valid?
      assert_not VkLaunchParams.new(params.to_query).valid?, "без подписи пускать нельзя"
    end
  end

  test "на переезде принимаются подписи обоих приложений" do
    old_secret = "oldoldoldoldoldoldol"
    params = { "vk_user_id" => "42", "vk_app_id" => "7" }

    payload = params.sort.to_h.to_query
    old_sign = Base64.urlsafe_encode64(OpenSSL::HMAC.digest("SHA256", old_secret, payload)).delete("=")

    ENV["VK_APP_SECRET"] = "#{old_secret}, #{SECRET}"

    begin
      assert VkLaunchParams.new(params.merge("sign" => old_sign).to_query).valid?, "старый ключ"
      assert VkLaunchParams.new(params.merge("sign" => sign(params)).to_query).valid?, "новый ключ"
      assert_not VkLaunchParams.new(params.merge("sign" => "чужая").to_query).valid?
    ensure
      ENV.delete("VK_APP_SECRET")
    end
  end

  test "просроченные параметры запуска отклоняются" do
    params = { "vk_user_id" => "42", "vk_ts" => 2.days.ago.to_i.to_s }

    with_secret do
      assert_not VkLaunchParams.new(params.merge("sign" => sign(params)).to_query).valid?
    end
  end
end
