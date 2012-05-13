class HomeController < ApplicationController
  
  def index
    @wanted_list = WantedToon.active_bounties
    @eden_heros = EdenHero.top_earning_order
    @total_bounty_pool = WantedToon.all.collect{|toon| toon.bounty}.sum
  end
  
end
