class AdsController < ApplicationController
  before_action :authenticate_user!, except: :index
  before_action :set_ad, only: %i[edit update destroy]

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

  # «Карточка питомца» и «Карточка временного хозяина» — одна форма на две роли.
  def new
    @ad = current_user.profile.ads.new(role: role_param, status: "published")
    @ad.prefill_from(current_user.profile) if @ad.sitter?
  end

  def create
    @ad = current_user.profile.ads.new(ad_params)
    @ad.status = "published"

    if @ad.save
      redirect_to profile_pets_path, notice: "Карточка добавлена"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @ad.update(ad_params)
      redirect_to profile_pets_path, notice: "Карточка сохранена"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ad.destroy
    redirect_to profile_pets_path, notice: "Карточка удалена"
  end

  private

  def set_ad
    @ad = current_user.profile.ads.find(params[:id])
  end

  def role_param
    Ad::ROLES.key?(params[:role]) ? params[:role] : Ad::PET
  end

  def ad_params
    params.require(:ad).permit(:title, :kind, :role, :age, :breed, :activity,
                               :city, :period, :description, :photo)
  end
end
