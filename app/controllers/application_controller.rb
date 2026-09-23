class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # В форме регистрации из макета четыре поля: имя, почта, логин и пароль.
  # Имя уезжает в профиль. Почту разрешаем явно: ключ входа теперь логин,
  # и сам Devise её больше не пропускает.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :login, :name, :email ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :login, :email ])
  end
end
