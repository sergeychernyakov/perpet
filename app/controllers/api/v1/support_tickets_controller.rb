module Api
  module V1
    class SupportTicketsController < BaseController
      def create
        ticket = SupportTicket.new(ticket_params)

        if ticket.save
          render json: { reference: ticket.reference, email: ticket.email, topic: ticket.topic },
                 status: :created
        else
          render json: { errors: ticket.error_messages }, status: :unprocessable_entity
        end
      end

      private

      def ticket_params
        params.require(:support_ticket).permit(:name, :email, :topic, :message)
      end
    end
  end
end
