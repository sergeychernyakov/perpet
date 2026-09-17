# Шаги «Передержка с Perpet» на странице «Знакомство с нами».
# Раскладка та же, что у промо-карточек: доли от ширины карточки из макета.
class Step < Data.define(:title, :text, :cta, :icon, :route,
                         :art_left, :art_top, :art_width, :art_ratio, :art_transform,
                         :text_left, :text_width, :align, :justify, :title_width)
  def self.all
    [
      new(title: "Зарегистрируйтесь в Perpet",
          text: "Если у Вас еще нет профиля, то создайте новый. Если Вы уже стали частью нашей команды, то просто войдите в аккаунт.",
          cta: "Профиль", route: :profile_path, icon: "promo-cat.svg",
          art_left: "7.243%", art_top: "7.192cqw", art_width: "110.021%",
          art_ratio: "642.52 / 475.464", art_transform: "matrix(0.729,0.684,-0.684,0.729,0,0)",
          text_left: "37.329%", text_width: "54.110%", align: "right", justify: "flex-end",
          title_width: nil),
      new(title: "Ознакомьтесь с полезными темами",
          text: "Если Вы все таки решили отказаться от поездки с питомцем после изучения всех нюансов, то положитесь на нас.",
          cta: "Читать", route: :articles_path, icon: "promo-paw.svg",
          art_left: "34.589%", art_top: "54.966cqw", art_width: "30.933%",
          art_ratio: "180.647 / 349.295", art_transform: "none",
          text_left: "24.658%", text_width: "50.685%", align: "center", justify: "center",
          title_width: nil),
      new(title: "Создайте обьявление и свяжитесь с желающими",
          text: "В своем профиле Вы сможете добавить обьявление о поиске временных хозяев. Так, другие узнают о Вас и смогут откликнуться.",
          cta: "Обьявления", route: :ads_path, icon: "promo-hand.svg",
          art_left: "111.634%", art_top: "38.000cqw", art_width: "61.639%",
          art_ratio: "359.974 / 466.693", art_transform: "matrix(-1,0.014,0.014,1,0,0)",
          text_left: "8.562%", text_width: "54.110%", align: "left", justify: "flex-start",
          title_width: "154%")
    ]
  end
end
