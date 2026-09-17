class ArticlesController < ApplicationController
  def index
    @pager = Paginator.new(Article.ordered, page: params[:page])
    @articles = @pager.records
  end

  def show
    @article = Article.find(params[:id])
    @more = Article.ordered.where.not(id: @article.id).limit(2)
  end
end
