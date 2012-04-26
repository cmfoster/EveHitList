class HomeController < ApplicationController
  
  def index
    @wanted_list = WantedToon.all
  end
  
end
