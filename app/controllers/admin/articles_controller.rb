module Admin
  class ArticlesController < BaseController
    before_action :set_article, only: %i[edit update destroy]

    def index
      @articles = Article.ordered
    end

    def new
      @article = Article.new(position: Article.maximum(:position).to_i + 1)
    end

    def create
      @article = Article.new(article_params)

      if @article.save
        redirect_to admin_articles_path, notice: "Статья создана"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @article.update(article_params)
        redirect_to admin_articles_path, notice: "Статья сохранена"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @article.destroy
      redirect_to admin_articles_path, notice: "Статья удалена", status: :see_other
    end

    private

    def set_article
      @article = Article.find(params[:id])
    end

    def article_params
      params.require(:article).permit(:title, :tag, :excerpt, :body, :read_time, :position)
    end
  end
end
