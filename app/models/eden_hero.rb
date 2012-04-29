class EdenHero < ActiveRecord::Base
  scope :top_earning_order, :order => 'earned_bounty_amt DESC'
  attr_accessible :character_id, :earned_bounty_amt, :name
end
