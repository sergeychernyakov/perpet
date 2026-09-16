class ArticlesController < ApplicationController
  def index
    @pager = Paginator.new(Article.ordered, page: params[:page])
    @articles = @pager.records
  end
end
