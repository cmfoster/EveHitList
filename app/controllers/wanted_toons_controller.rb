class WantedToonsController < ApplicationController
  
  def gettoons
    @wanted_toon = WantedToon.find_by_character_id(params[:character_id])
  end
end
