require "test_helper"

class PaginatorTest < ActiveSupport::TestCase
  setup do
    7.times { |i| Article.create!(title: "Статья #{i}", position: i) }
    @scope = Article.ordered
  end

  test "считает страницы и отдаёт записи текущей" do
    pager = Paginator.new(@scope, page: 2, per_page: 6)

    assert_equal 7, pager.total
    assert_equal 2, pager.pages
    assert_equal 1, pager.records.size
    assert pager.many?
    assert pager.last?
    assert_equal "Страница 2 из 2", pager.label
  end

  test "номер страницы ограничивается допустимым диапазоном" do
    assert_equal 1, Paginator.new(@scope, page: 0).page
    assert_equal 2, Paginator.new(@scope, page: 99, per_page: 6).page
  end

  test "пустая выборка — одна страница" do
    pager = Paginator.new(Article.where(id: nil), page: 1)

    assert_equal 1, pager.pages
    assert_not pager.many?
  end
end
