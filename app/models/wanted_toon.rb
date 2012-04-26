class WantedToon < ActiveRecord::Base
  has_many :wt_ships
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
  
  
end
