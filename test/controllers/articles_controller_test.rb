require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "список статей открывается" do
    Article.create!(title: "Как везти кота", excerpt: "Коротко о главном.")

    get articles_path

    assert_response :success
    assert_select ".article", 1
  end

  test "с карточки есть ссылка на саму статью" do
    article = Article.create!(title: "Как везти кота", tag: "Перевозка, Документы",
                              read_time: "5 минут", excerpt: "Коротко о главном.",
                              body: "Первый абзац.\n\nВторой абзац.")

    get articles_path

    assert_select ".article__title a[href=?]", article_path(article), text: article.title
    assert_select ".article__arrow[href=?]", article_path(article)
  end

  test "страница статьи показывает текст и метки" do
    article = Article.create!(title: "Как везти кота", tag: "Перевозка, Документы",
                              read_time: "5 минут", excerpt: "Коротко о главном.",
                              body: "Первый абзац.\n\nВторой абзац.")

    get article_path(article)

    assert_response :success
    assert_select "h1", "Как везти кота"
    assert_select ".reading__text", 2
    assert_select ".reading__lead", "Коротко о главном."
    assert_select ".reading__tags .tag", 3
  end
end
