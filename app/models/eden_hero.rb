class EdenHero < ActiveRecord::Base
  scope :top_earning_order, :order => 'earned_bounty_amt DESC', :conditions => ['earned_bounty_amt > 0 '], :limit => 6
  attr_accessible :character_id, :earned_bounty_amt, :name
end
