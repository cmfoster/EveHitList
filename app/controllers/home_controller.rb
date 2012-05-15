class HomeController < ApplicationController
  
  def index
    @wanted_list = WantedToon.active_bounties.page params[:page]
    @eden_heros = EdenHero.top_earning_order
    @total_bounty_pool = WantedToon.all.collect{|toon| toon.bounty}.sum
  end
  
  def testfbpage
    @uri = "http://" + request.headers["HTTP_HOST"] + request.headers["PATH_INFO"]
    # redirect_to :action => :index
  end
  
end
