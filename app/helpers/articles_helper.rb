module ArticlesHelper
  # Рисунки блоков статьи. Где каждый из них стоит и как повёрнут —
  # в pages/articles.css: координаты и матрицы взяты прямо из макета.
  ART_IMAGES = {
    "cat" => "ab-cat-big.svg",
    "plus" => "hero-19.svg",
    "minus" => "ear-cream.svg",
    "hand" => "paw-coral-1.svg",
    "hand-right" => "hero-19.svg"
  }.freeze

  # Рука у пункта в макете каждый раз своя: сначала один палец, потом два,
  # потом три — и дальше по кругу. Салатовые руки те же, что на главной.
  PAW_IMAGES = {
    "lime" => %w[shape-14.svg shape-16.svg shape-13.svg],
    "coral" => %w[paw-coral-1.svg hero-19.svg paw-coral-3.svg]
  }.freeze

  def article_art(art)
    return unless ART_IMAGES.key?(art)

    image_tag ART_IMAGES[art], alt: "", class: "reading__art reading__art--#{art}"
  end

  def article_paw(tone, index)
    paws = PAW_IMAGES.fetch(tone, PAW_IMAGES["lime"])

    paws[index % paws.size]
  end
end
