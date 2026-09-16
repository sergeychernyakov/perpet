module Admin
  class SupportTicketsController < BaseController
    def index
      @pager = paginate(SupportTicket.order(created_at: :desc))
      @tickets = @pager.records
    end

    def destroy
      SupportTicket.find(params[:id]).destroy
      redirect_to admin_support_tickets_path, notice: "Обращение удалено", status: :see_other
    end
  end
end
