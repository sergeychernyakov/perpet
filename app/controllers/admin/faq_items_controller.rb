module Admin
  class FaqItemsController < BaseController
    before_action :set_item, only: %i[edit update destroy]

    def index
      @items = FaqItem.ordered
    end

    def new
      @item = FaqItem.new(position: FaqItem.maximum(:position).to_i + 1)
    end

    def create
      @item = FaqItem.new(item_params)

      if @item.save
        redirect_to admin_faq_items_path, notice: "Вопрос добавлен"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @item.update(item_params)
        redirect_to admin_faq_items_path, notice: "Вопрос сохранён"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @item.destroy
      redirect_to admin_faq_items_path, notice: "Вопрос удалён", status: :see_other
    end

    private

    def set_item
      @item = FaqItem.find(params[:id])
    end

    def item_params
      params.require(:faq_item).permit(:question, :answer, :position)
    end
  end
end
