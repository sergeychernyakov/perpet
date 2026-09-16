# Промо-карточки главной страницы. Это оформление, а не данные сервиса,
# поэтому живут в коде, а не в базе.
class Promo < Data.define(:title, :text, :cta, :icon, :offset_x, :width, :route)
  def self.all
    [
      new(title: "Изучи полезные статьи",
          text: "Что писать в объявлении, как проверить хозяина и о чём договориться заранее.",
          cta: "Читать", icon: "shape-17.svg", offset_x: "-18%", width: "70%", route: :articles_path),
      new(title: "Найди временных хозяев",
          text: "Шесть свежих объявлений в пяти городах — с фильтрами по виду питомца.",
          cta: "Смотреть объявления", icon: "shape-18.svg", offset_x: "30%", width: "34%", route: :ads_path),
      new(title: "Заведи свой профиль",
          text: "Добавьте карточку питомца, сроки и условия — отклики придут на почту.",
          cta: "Профиль", icon: "shape-19.svg", offset_x: "44%", width: "62%", route: :profile_path)
    ]
  end
end
