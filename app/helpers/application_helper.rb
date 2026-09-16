module ApplicationHelper
  def nav_link(title, path)
    link_to title, path, class: class_names("nav__link", "nav__link--current" => current_page?(path))
  end

  # Первое сообщение об ошибке — в формах макета показывается одна строка.
  def error_message_for(record)
    record.error_messages.first
  end

  # Кнопка, открывающая форму заявки: join — «присоединиться», respond — отклик на объявление.
  def modal_button(label, kind: "join", subject: nil, css: "btn")
    button_tag(label, type: "button", class: css,
               data: { action: "modal#open", modal_kind_param: kind, modal_subject_param: subject })
  end
end
