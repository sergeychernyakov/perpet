class SupportController < ApplicationController
  def show
    @channels = SupportChannel.ordered
    @faq = FaqItem.ordered
    @ticket = SupportTicket.new(topic: SupportTicket::TOPICS.first)
  end
end
