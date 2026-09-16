class AdsController < ApplicationController
  def index
    @kind = params[:kind].presence || Ad::ALL_KINDS
    @query = params[:q].to_s.strip

    scope = Ad.published.of_kind(@kind).search(@query).recent
    @total = Ad.published.count
    @pager = Paginator.new(scope, page: params[:page])
    @ads = @pager.records
  end

  # Черновик объявления из профиля: заполняется дальше в карточке.
  def create
    Profile.current.ads.create!(
      kind: Ad::KINDS.first,
      title: "Новое объявление",
      description: "Заполните описание питомца и сроки передержки.",
      icon: "shape-04.svg",
      status: "draft"
    )

    redirect_to profile_path, notice: "Черновик объявления создан"
  end
end
