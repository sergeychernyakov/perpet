module Admin
  class DashboardController < BaseController
    def index
      @counts = {
        "Объявления" => Ad.count,
        "Опубликованы" => Ad.published.count,
        "Черновики" => Ad.drafts.count,
        "Статьи" => Article.count,
        "Вопросы FAQ" => FaqItem.count,
        "Каналы поддержки" => SupportChannel.count,
        "Обращения" => SupportTicket.count,
        "Заявки" => Lead.count,
        "Пользователи" => User.count
      }

      @tickets = SupportTicket.order(created_at: :desc).limit(5)
      @leads = Lead.order(created_at: :desc).limit(5)
    end
  end
end
