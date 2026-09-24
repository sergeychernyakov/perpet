require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  test "строка «~ cat» задаёт рисунок блока и в тексте не остаётся" do
    article = Article.new(title: "Тест", body: "Первый абзац.\n~ cat")
    block = article.layout.first

    assert_equal "cat", block[:art]
    assert_equal "Первый абзац.", block[:text]
  end

  test "рисунок достаётся и колонке с заливкой" do
    article = Article.new(title: "Тест", body: "@@ Плюсы\n~ plus\n\nТекст внутри.")
    column = article.layout.first[:columns].first

    assert_equal "plus", column[:art]
    assert_equal "Плюсы", column[:title]
  end

  test "незнакомое имя рисунка остаётся обычным текстом" do
    article = Article.new(title: "Тест", body: "Абзац.\n~ слон")
    block = article.layout.first

    assert_nil block[:art]
    assert_equal "Абзац.\n~ слон", block[:text]
  end

  test "читать целиком можно только статьи с текстом" do
    Article.create!(title: "С текстом", body: "Абзац.")
    Article.create!(title: "Анонс")

    assert_equal [ "С текстом" ], Article.readable.pluck(:title)
  end
end
