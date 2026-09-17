module Api
  module V1
    class AdsController < BaseController
      before_action :authenticate!, only: %i[mine create update destroy]

      def index
        scope = Ad.published.of_kind(params[:kind]).search(params[:q]).recent
        render_page(Paginator.new(scope, page: page), :ads, all: Ad.published.count, &:as_api)
      end

      def show
        render json: { ad: Ad.published.find(params[:id]).as_api }
      end

      def mine
        render json: { ads: current_profile.ads.recent.map(&:as_api) }
      end

      def create
        ad = current_profile.ads.new(ad_params)
        ad.status ||= "draft"

        if ad.save
          render json: { ad: ad.as_api }, status: :created
        else
          render json: { errors: ad.error_messages }, status: :unprocessable_entity
        end
      end

      def update
        ad = current_profile.ads.find(params[:id])

        if ad.update(ad_params)
          render json: { ad: ad.as_api }
        else
          render json: { errors: ad.error_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        current_profile.ads.find(params[:id]).destroy
        head :no_content
      end

      private

      def ad_params
        params.require(:ad).permit(:title, :kind, :city, :period, :price, :description, :icon, :status, :photo)
      end
    end
  end
end
