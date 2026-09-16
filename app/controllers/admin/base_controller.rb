module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin

    # В таблицах админки строки короткие, поэтому на страницу их влезает
    # заметно больше, чем в карточки на сайте.
    PER_PAGE = 25

    private

    def require_admin
      return if current_user.admin?

      redirect_to root_path, alert: "Раздел доступен только администраторам"
    end

    def paginate(scope)
      Paginator.new(scope, page: params[:page], per_page: PER_PAGE)
    end
  end
end
