class HomeController < ApplicationController
  
  def index
    @wanted_list = WantedToon.active_bounties
    @eden_heros = EdenHero.top_earning_order
  end
  
end
