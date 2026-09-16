class SupportTicketsController < ApplicationController
  def create
    @ticket = SupportTicket.new(ticket_params)

    if @ticket.save
      render turbo_stream: turbo_stream.update("ticket", partial: "support/ticket_sent", locals: { ticket: @ticket })
    else
      render turbo_stream: turbo_stream.update("ticket", partial: "support/ticket_form", locals: { ticket: @ticket }),
             status: :unprocessable_entity
    end
  end

  private

  def ticket_params
    params.require(:support_ticket).permit(:name, :email, :topic, :message)
  end
end
