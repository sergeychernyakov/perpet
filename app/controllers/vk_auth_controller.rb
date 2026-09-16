# Вход и привязка ВКонтакте на сайте.
#
# /auth/vk          — уводит на VK ID
# /auth/vk/callback — принимает ответ и сажает человека в аккаунт
class VkAuthController < ApplicationController
  def create
    return redirect_with_alert("Вход через ВКонтакте не настроен") unless VkId.configured?

    verifier = VkId.verifier
    state = SecureRandom.urlsafe_base64(24)

    session[:vk_verifier] = verifier
    session[:vk_state] = state

    redirect_to VkId.authorize_url(redirect_uri: callback_url, state: state, verifier: verifier),
                allow_other_host: true
  end

  def callback
    verifier = session.delete(:vk_verifier)
    expected_state = session.delete(:vk_state)

    return redirect_with_alert("Вход через ВКонтакте отменён") if params[:code].blank?
    return redirect_with_alert("Не удалось проверить ответ ВКонтакте") unless valid_state?(expected_state)

    person = VkId.person(code: params[:code], device_id: params[:device_id],
                         verifier: verifier, redirect_uri: callback_url)

    user_signed_in? ? link_to_current_user(person) : sign_in_with(person)
  rescue VkId::Error => e
    redirect_with_alert("ВКонтакте: #{e.message}")
  end

  private

  def callback_url
    auth_vk_callback_url(protocol: request.ssl? ? "https" : "http")
  end

  def valid_state?(expected)
    expected.present? && params[:state].present? &&
      ActiveSupport::SecurityUtils.secure_compare(params[:state], expected)
  end

  # Человек уже вошёл по почте — просто привязываем к его аккаунту страницу VK.
  def link_to_current_user(person)
    taken = User.where(vk_id: person.vk_id).where.not(id: current_user.id).exists?
    return redirect_to(profile_path, alert: "Эта страница ВКонтакте уже привязана к другому аккаунту") if taken

    current_user.update!(vk_id: person.vk_id)
    current_user.profile&.fill_missing_from_vk(person)

    redirect_to profile_path, notice: "ВКонтакте привязан"
  end

  def sign_in_with(person)
    user = User.from_vk_id(person)
    sign_in(user)
    user.profile&.fill_missing_from_vk(person)

    redirect_to profile_path, notice: "Вход через ВКонтакте выполнен"
  end

  def redirect_with_alert(message)
    redirect_to(user_signed_in? ? profile_path : new_user_session_path, alert: message)
  end
end
