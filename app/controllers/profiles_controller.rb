class ProfilesController < ApplicationController
  before_action :set_profile

  def show
    @ads = @profile.ads.recent
  end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path, notice: "Профиль сохранён"
    else
      @ads = @profile.ads.recent
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = Profile.current
  end

  def profile_params
    params.require(:profile).permit(:name, :city, :email)
  end
end
