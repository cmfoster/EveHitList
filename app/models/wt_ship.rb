class WtShip < ActiveRecord::Base
  belongs_to :wanted_toon
  after_create :reduce_toon_bounty, :unless => "self.wanted_toon.bounty <= 0"
                                    #deduct bounty amount, only when toon bounty is greater then payout ammount. 
                                   #Logic for payouts greater then bounty in wanted_too.rb
  attr_accessible :isk_destroyed, :isk_dropped, :lossurl, :payout_amt, :ship_type, 
      :solar_system, :wanted_toon_id, :eve_time_date, :lost_to
      
      private
        def reduce_toon_bounty
          self.wanted_toon.bounty -= self.payout_amt
          self.wanted_toon.save
        end
end
