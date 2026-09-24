module ArticlesHelper
  # Рисунки блоков статьи. Где каждый из них стоит и как повёрнут —
  # в pages/articles.css: координаты и матрицы взяты прямо из макета.
  ART_IMAGES = {
    "cat" => "ab-cat-big.svg",
    "plus" => "hero-19.svg",
    "minus" => "ear-cream.svg",
    "hand" => "hero-19.svg",
    "hand-right" => "hero-19.svg"
  }.freeze

  def article_art(art)
    return unless ART_IMAGES.key?(art)

    image_tag ART_IMAGES[art], alt: "", class: "reading__art reading__art--#{art}"
  end
end
