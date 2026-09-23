class AdsController < ApplicationController
  before_action :authenticate_user!, only: :create

  # В макете два раздела: объявления питомцев и объявления ситтеров.
  # Поиск и фильтр по виду питомца макет не рисует, но на полтора десятка
  # карточек без них не обойтись, поэтому они остались под переключателем.
  def index
    @role = Ad::ROLES.key?(params[:role]) ? params[:role] : Ad::PET
    @kind = params[:kind].presence || Ad::ALL_KINDS
    @query = params[:q].to_s.strip

    scope = Ad.published.of_role(@role).of_kind(@kind).search(@query).recent
    @total = Ad.published.of_role(@role).count
    @pager = Paginator.new(scope, page: params[:page])
    @ads = @pager.records
  end

  # Черновик объявления из профиля: заполняется дальше в карточке.
  def create
    current_user.profile.ads.create!(
      kind: Ad::KINDS.first,
      title: "Новое объявление",
      description: "Заполните описание питомца и сроки передержки.",
      icon: "shape-04.svg",
      status: "draft"
    )

    redirect_to profile_path, notice: "Черновик объявления создан"
  end
end
