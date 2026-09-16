module Api
  module V1
    class ArticlesController < BaseController
      def index
        render_page(Paginator.new(Article.ordered, page: page), :articles, &:as_api)
      end

      def show
        render json: { article: Article.find(params[:id]).as_api }
      end
    end
  end
end
