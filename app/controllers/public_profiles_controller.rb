# «Карточка пользователя» из макета: кто стоит за объявлением.
# Показываем только тех, у кого есть опубликованные объявления, — чужой
# профиль сам по себе не публичная страница.
class PublicProfilesController < ApplicationController
  def show
    @profile = Profile.joins(:ads).where(ads: { status: "published" }).distinct.find(params[:id])
    @ads = @profile.ads.published.recent
  end
end
