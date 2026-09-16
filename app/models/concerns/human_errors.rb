# Сообщения об ошибках так, как их видит человек.
#
# Стандартные сообщения — фрагменты («не может быть пустым»), к ним нужно
# название поля: «Заголовок не может быть пустым». А свои сообщения в моделях
# уже написаны целиком («Проверьте e-mail»), и приписывать к ним название поля
# не нужно — получилось бы «E-mail Проверьте e-mail».
module HumanErrors
  extend ActiveSupport::Concern

  def error_messages
    errors.map do |error|
      error.options[:message].is_a?(String) ? error.message : error.full_message
    end
  end
end
