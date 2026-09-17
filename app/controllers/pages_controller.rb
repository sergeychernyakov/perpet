class PagesController < ApplicationController
  def home
    @promos = Promo.all
    @advantages = Advantage.all
  end

  def about
    @benefits = Benefit.all
    @steps = Step.all
  end

  def brand
    @facets = Brand.facets
    @values = Brand.values
    @promos = Promo.all
  end
end
