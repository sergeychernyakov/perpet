module Admin
  class AdsController < BaseController
    before_action :set_ad, only: %i[edit update destroy]

    def index
      @ads = Ad.recent
    end

    def new
      @ad = Ad.new(status: "published", published_on: Date.current)
    end

    def create
      @ad = Ad.new(ad_params)

      if @ad.save
        redirect_to admin_ads_path, notice: "Объявление создано"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @ad.update(ad_params)
        redirect_to admin_ads_path, notice: "Объявление сохранено"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @ad.destroy
      redirect_to admin_ads_path, notice: "Объявление удалено", status: :see_other
    end

    private

    def set_ad
      @ad = Ad.find(params[:id])
    end

    def ad_params
      params.require(:ad).permit(:title, :kind, :city, :period, :price, :description, :icon, :status, :published_on)
    end
  end
end
