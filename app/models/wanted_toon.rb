class WantedToon < ActiveRecord::Base
  attr_accessible :bounty, :character_id, :name
  
#   Remember this to gsub the EAAL::API::CORP::WALLETJOURNAL result  s.entries.first.reason.gsub(/[DECS:\s]/, "")
#   RefType 10 = Player Donation <= is what i am looking for only
#   s.request_time.to_time = Keep an eye on this to reference next transaction to read.
  
  def make_wanted_toon(name,characterid,bounty)
    
  end
end
