module Admin
  class SupportChannelsController < BaseController
    before_action :set_channel, only: %i[edit update destroy]

    def index
      @channels = SupportChannel.ordered
    end

    def new
      @channel = SupportChannel.new(position: SupportChannel.maximum(:position).to_i + 1)
    end

    def create
      @channel = SupportChannel.new(channel_params)

      if @channel.save
        redirect_to admin_support_channels_path, notice: "Канал добавлен"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @channel.update(channel_params)
        redirect_to admin_support_channels_path, notice: "Канал сохранён"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @channel.destroy
      redirect_to admin_support_channels_path, notice: "Канал удалён", status: :see_other
    end

    private

    def set_channel
      @channel = SupportChannel.find(params[:id])
    end

    def channel_params
      params.require(:support_channel).permit(:title, :availability, :description, :value, :href, :position)
    end
  end
end
