module Admin
  class LeadsController < BaseController
    def index
      @leads = Lead.order(created_at: :desc)
    end

    def destroy
      Lead.find(params[:id]).destroy
      redirect_to admin_leads_path, notice: "Заявка удалена", status: :see_other
    end
  end
end
