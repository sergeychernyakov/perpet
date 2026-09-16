class LeadsController < ApplicationController
  def create
    @lead = Lead.new(lead_params)

    if @lead.save
      render turbo_stream: turbo_stream.update("modal-body", partial: "shared/modal_sent", locals: { lead: @lead })
    else
      render turbo_stream: turbo_stream.update("modal-body", partial: "shared/modal_form", locals: { lead: @lead }),
             status: :unprocessable_entity
    end
  end

  private

  def lead_params
    params.require(:lead).permit(:name, :email, :city, :kind, :subject)
  end
end
