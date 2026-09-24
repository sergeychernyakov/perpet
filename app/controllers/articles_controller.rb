class ArticlesController < ApplicationController
  def index
    @pager = Paginator.new(Article.ordered, page: params[:page])
    @articles = @pager.records
  end

  # Открыть целиком можно только статью с текстом: у остальных карточек в
  # списке и ссылки-то нет, но прямой адрес тоже не должен показывать пустоту.
  def show
    @article = Article.readable.find(params[:id])
  end
end
