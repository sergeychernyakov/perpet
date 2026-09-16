# Шаги «Передержка с Perpet» на странице «Знакомство с нами».
# route: nil — кнопка открывает форму заявки.
class Step < Data.define(:title, :text, :cta, :icon, :offset_x, :width, :route)
  def self.all
    [
      new(title: "Зарегистрируйтесь в Perpet",
          text: "Если профиля ещё нет — создайте новый. Если вы уже с нами, просто войдите в аккаунт.",
          cta: "Регистрация", icon: "shape-48.svg", offset_x: "-14%", width: "72%", route: nil),
      new(title: "Ознакомьтесь с полезными темами",
          text: "Если вы решили отказаться от поездки с питомцем после изучения нюансов — положитесь на нас.",
          cta: "Статьи", icon: "shape-47.svg", offset_x: "34%", width: "32%", route: :articles_path),
      new(title: "Создайте объявление и свяжитесь с желающими",
          text: "В профиле можно добавить объявление о поиске временных хозяев — другие узнают о вас и откликнутся.",
          cta: "Профиль", icon: "shape-46.svg", offset_x: "42%", width: "64%", route: :profile_path)
    ]
  end
end
