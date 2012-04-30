class AddNewTarget
  @queue = :check_wallet_queue
  
  def self.perform(test_time=nil)
    EAAL::API.new("","","eve").characterInfo(:characterID => 1436418183)
    EveApiChecker.check_corp_journal_for_new_donations(test_time)
  end
end