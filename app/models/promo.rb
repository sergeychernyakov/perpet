# Промо-карточки главной страницы. Это оформление, а не данные сервиса,
# поэтому живут в коде, а не в базе.
#
# Рисунок в карточке выложен по макету: доли от ширины карточки и матрица
# поворота из Figma. Поэтому у каждой карточки свои art_* и text_*.
class Promo < Data.define(:title, :text, :cta, :icon, :route,
                          :art_left, :art_top, :art_width, :art_ratio, :art_transform,
                          :text_left, :text_width, :align)
  def self.all
    [
      new(title: "Изучи полезные статьи",
          text: "Мы регулярно актуализируем статьи по перевозке питомцев, а также о том, как правильно избежать стресса при передержке.",
          cta: "Читать", route: :articles_path, icon: "promo-cat.svg",
          art_left: "7.251%", art_top: "7.434%", art_width: "110.146%",
          art_ratio: "642.52 / 475.464", art_transform: "matrix(0.729,0.684,-0.684,0.729,0,0)",
          text_left: "47.333%", text_width: "46.667%", align: "right"),
      new(title: "Откликнись сам стать временным хозяином",
          text: "Если Вы любите животных и понимаете, что готовы помочь, то заполняйте профиль и позаботьтесь о чужом питомце как о своем.",
          cta: "Профиль", route: :profile_path, icon: "promo-paw.svg",
          art_left: "34.629%", art_top: "56.814%", art_width: "30.968%",
          art_ratio: "180.647 / 349.295", art_transform: "none",
          text_left: "16.237%", text_width: "67.526%", align: "center"),
      new(title: "Найди временных хозяев",
          text: "Если Вы приняли решение ехать без питомца, дайте возможность позаботиться об этом нам.",
          cta: "Обьявления", route: :ads_path, icon: "promo-hand.svg",
          art_left: "111.760%", art_top: "27.965%", art_width: "61.710%",
          art_ratio: "359.974 / 466.693", art_transform: "matrix(-1,0.014,0.014,1,0,0)",
          text_left: "6.000%", text_width: "51.943%", align: "left")
    ]
  end
end
