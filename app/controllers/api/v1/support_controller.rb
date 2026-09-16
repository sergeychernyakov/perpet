module Api
  module V1
    # Справочные данные страницы поддержки: каналы связи и вопросы.
    class SupportController < BaseController
      def show
        render json: {
          channels: SupportChannel.ordered.map { |channel|
            { id: channel.id, title: channel.title, availability: channel.availability,
              description: channel.description, value: channel.value, href: channel.href }
          },
          faq: FaqItem.ordered.map { |item| { id: item.id, question: item.question, answer: item.answer } },
          topics: SupportTicket::TOPICS
        }
      end
    end
  end
end
