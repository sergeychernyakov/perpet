module Api
  module V1
    class ArticlesController < BaseController
      def index
        render_page(Paginator.new(Article.ordered, page: page), :articles, &:as_api)
      end

      # Как и на сайте: целиком отдаём только статью с текстом.
      def show
        render json: { article: Article.readable.find(params[:id]).as_api }
      end
    end
  end
end
