module Admin
  class LeadsController < BaseController
    def index
      @pager = paginate(Lead.order(created_at: :desc))
      @leads = @pager.records
    end

    def destroy
      Lead.find(params[:id]).destroy
      redirect_to admin_leads_path, notice: "Заявка удалена", status: :see_other
    end
  end
end
