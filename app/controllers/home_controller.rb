class HomeController < ApplicationController
  
  def index
    @wanted_list = WantedToon.all
    @eden_heros = EdenHero.top_earning_order
  end
  
end
