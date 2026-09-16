class PagesController < ApplicationController
  def home
    @promos = Promo.all
    @advantages = Advantage.all
  end

  def about
    @benefits = Benefit.all
    @steps = Step.all
  end
end
