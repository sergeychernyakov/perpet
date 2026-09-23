module Api
  module V1
    # «Карточка пользователя»: кто стоит за объявлением.
    class PublicProfilesController < BaseController
      def show
        profile = Profile.joins(:ads).where(ads: { status: "published" }).distinct.find(params[:id])

        render json: { profile: profile.as_api, ads: profile.ads.published.recent.map(&:as_api) }
      end
    end
  end
end
