class WtShip < ActiveRecord::Base
  belongs_to :wanted_toon
  attr_accessible :isk_destroyed, :isk_dropped, :lossurl, :payout_amt, :ship_type, 
      :solar_system, :wanted_toon_id, :eve_time_date
end