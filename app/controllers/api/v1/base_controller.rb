module Api
  module V1
    # Общая база для API мини-приложения VK: JSON, без сессий и CSRF.
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      private

      # Мини-приложение присылает строку параметров запуска в заголовке
      # X-VK-Launch-Params (или в ?vk_params= — так удобнее отлаживать).
      def launch_params
        @launch_params ||= VkLaunchParams.new(
          request.headers["X-VK-Launch-Params"].presence || params[:vk_params]
        )
      end

      def current_user
        return @current_user if defined?(@current_user)

        @current_user = launch_params.valid? ? User.for_vk(launch_params.user_id) : nil
      end

      def current_profile
        current_user&.profile
      end

      def authenticate!
        return if current_user

        render json: { error: "Не удалось проверить параметры запуска VK" }, status: :unauthorized
      end

      def not_found
        render json: { error: "Не найдено" }, status: :not_found
      end

      def page
        params[:page].to_i
      end

      def render_page(paginator, key, &block)
        render json: {
          key => paginator.records.map(&block),
          meta: {
            page: paginator.page,
            pages: paginator.pages,
            total: paginator.total,
            per_page: paginator.per_page
          }
        }
      end
    end
  end
end
