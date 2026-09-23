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

  test "статья без текста не ссылка и не открывается" do
    article = Article.create!(title: "Скоро напишем", excerpt: "Анонс будущей темы.")

    get articles_path

    assert_select ".article__title a", 0
    assert_select ".article__arrow", 0

    get article_path(article)
    assert_response :not_found
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

  test "текст статьи разбирается на подзаголовки и списки" do
    article = Article.create!(title: "Как везти кота", excerpt: "Коротко о главном.",
                              body: "Вступление.\n\n## Что взять\n\n- Переноска.\n- Пеленки.")

    get article_path(article)

    assert_select ".reading__subtitle", "Что взять"
    assert_select ".reading__list li", 2
  end
end
