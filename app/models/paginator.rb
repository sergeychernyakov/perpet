# Постраничная навигация без внешних гемов: знает текущую страницу,
# общее число страниц и умеет отдавать записи текущей страницы.
class Paginator
  PER_PAGE = 6

  attr_reader :page, :pages, :total, :per_page

  def initialize(scope, page:, per_page: PER_PAGE)
    @scope = scope
    @per_page = per_page
    @total = scope.count
    @pages = [ (total.to_f / per_page).ceil, 1 ].max
    @page = page.to_i.clamp(1, pages)
  end

  def records
    @records ||= @scope.offset((page - 1) * per_page).limit(per_page)
  end

  def many?
    pages > 1
  end

  def first?
    page <= 1
  end

  def last?
    page >= pages
  end

  def label
    "Страница #{page} из #{pages}"
  end

  def page_numbers
    (1..pages)
  end
end
