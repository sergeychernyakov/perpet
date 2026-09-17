module Api
  module V1
    # Оформление главной, «О нас» и бренд-бука: те же данные, что на сайте,
    # чтобы мини-приложение не расходилось с ним по текстам.
    class ContentController < BaseController
      def show
        render json: {
          advantages: Advantage.all.map { |item| { text: item.text, icon: asset(item.icon) } },
          promos: Promo.all.map { |promo| card(promo) },
          benefits: Benefit.all.map { |item| { text: item.text, icon: asset(item.icon) } },
          steps: Step.all.map { |step| card(step) },
          brand: {
            summary: Brand::SUMMARY, essence: Brand::ESSENCE, merch: Brand::MERCH,
            swatches: Brand::SWATCHES,
            facets: Brand.facets.map { |facet| { title: facet.title, text: facet.text } },
            values: Brand.values.map { |value| { title: value.title, text: value.text } }
          }
        }
      end

      private

      # Вместе с текстом отдаём и раскладку рисунка: мини-приложение рисует
      # карточку той же разметкой, что и сайт.
      def card(item)
        { title: item.title, text: item.text, cta: item.cta,
          icon: asset(item.icon), route: route_for(item.route),
          art_left: item.art_left, art_top: item.art_top, art_width: item.art_width,
          art_ratio: item.art_ratio, art_transform: item.art_transform,
          text_left: item.text_left, text_width: item.text_width,
          align: item.align, title_width: item.title_width }
      end

      # Мини-приложение живёт на хостинге VK, поэтому адреса картинок абсолютные.
      def asset(name)
        helpers.image_url(name)
      end

      def route_for(name)
        { articles_path: "articles", ads_path: "ads", profile_path: "profile" }[name] || "ads"
      end
    end
  end
end
