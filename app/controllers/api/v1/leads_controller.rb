module Api
  module V1
    class LeadsController < BaseController
      def create
        lead = Lead.new(lead_params)

        if lead.save
          render json: { message: lead.success_text }, status: :created
        else
          render json: { errors: lead.error_messages }, status: :unprocessable_entity
        end
      end

      private

      def lead_params
        params.require(:lead).permit(:name, :email, :city, :kind, :subject)
      end
    end
  end
end
