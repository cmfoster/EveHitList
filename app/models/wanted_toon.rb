class WantedToon < ActiveRecord::Base
  has_many :wt_ships, :order => :created_at
  attr_accessible :bounty, :character_id, :name
  
  def self.make_wanted_toon(name,characterid,bounty)
    wanted_toon = find_or_create_by_character_id(characterid)
    wanted_toon.name ||= name
    wanted_toon.bounty ? wanted_toon.bounty += bounty : wanted_toon.bounty = bounty
    if wanted_toon.save!
      return true
    else
      #create sendmail to admin with error and character information.
      return false
    end
  end
  
  #update_records => [[URI, SHIP TYPE, SYSTEM, TIME, ISK DESTROYED, ISK DROPPED, HERO_NAME, HERO CHARACTER ID, VERIFIED(BOOL)]]
  def update_toon_create_ship_record(update_records)
    update_records.each do |r|
      payout = ((r[4] - r[5]) * 0.65)
      if WtShip.find_by_lossurl(r[0]) #unless there is an exact time match for a record, create a new record
	      return false
      else
        if self.bounty < payout
          payout = self.bounty
          self.bounty = 0
          self.save
        end
  	    ship_lost = wt_ships.create!(:lossurl => r[0], :ship_type => r[1], :solar_system => r[2], :eve_time_date => r[3], 
  	      :isk_destroyed => r[4], :isk_dropped => r[5], :payout_amt => payout, :lost_to => r[6]
  			) # Payout, ttl destroyed isk - isk dropped * 65%
  			  			  
  			if r[6]
    			hero = EdenHero.find_or_initialize_by_character_id(r[7])
    			hero.name ||= r[6] 
    			hero.earned_bounty_amt? ? hero.earned_bounty_amt += payout : hero.earned_bounty_amt = payout #can't add to nil
    			if !hero.save #If record doesnt save.
    			  #mail admin
  			  end
			  end
      end
    end
  end
  
end
