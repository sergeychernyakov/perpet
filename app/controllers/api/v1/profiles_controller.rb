module Api
  module V1
    class ProfilesController < BaseController
      before_action :authenticate!

      def show
        render json: { profile: current_profile.as_api }
      end

      def update
        if current_profile.update(profile_params)
          render json: { profile: current_profile.as_api }
        else
          render json: { errors: current_profile.error_messages }, status: :unprocessable_entity
        end
      end

      private

      def profile_params
        params.require(:profile).permit(:name, :city, :email, :pet_name, :pet_age)
      end
    end
  end
end
