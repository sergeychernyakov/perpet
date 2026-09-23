class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile

  # Экран «Ваш профиль» из макета: информация, контакты и две плашки
  # с предложением завести карточку питомца или ситтера.
  def show
    @ads = @profile.ads.recent
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path, notice: "Профиль сохранён"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # «Ваши питомцы»: карточки, которые человек уже завёл.
  def pets
    @ads = @profile.ads.recent
  end

  private

  def set_profile
    @profile = current_user.profile
  end

  def profile_params
    params.require(:profile).permit(:name, :age, :city, :activity, :about, :phone,
                                    :email, :pet_name, :pet_age, :photo)
  end
end
