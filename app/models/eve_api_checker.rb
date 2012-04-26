class EveApiChecker 
  
  @@last_request_time = nil
  
  #check corporation wallet journal for all refTypeID's of 10(donations) and dated after last donation recieved.
  def self.check_corp_journal_for_new_donations(test_time=nil)
    acct = eve_api
    begin
      wallet = acct.walletjournal
      entries = wallet.entries
    rescue EAAL::Exception.EveAPIException(500)
      return false
    rescue EAAL::Exception.EveAPIException(904)
      return false
    end
    @@last_request_time ||= wallet.request_time.to_time #Set @@last_request_time in case this is the initial launch, which is would be nil.
    outlaw_names = entries.collect {
      |e| [e.reason.gsub(/[DECS:\n\r]/, ""), e.amount] if e.refTypeID.to_i == 10 && e.date.to_time > (test_time || @@last_request_time)
      }
  # return outlaw_names unless test_time.nil?
    outlaw_names.delete_if {|t| t == nil}
    outlaw_names.each{|d| d[0].gsub!(/^\s/, "")}
    log_api_access_time(wallet.request_time.to_time)
    get_character_id(acct, outlaw_names) if !outlaw_names.empty?
  end
  
  def self.eve_api
    EAAL::API.new(CORP_USER_ID, CORP_VCODE, "corp")
  end
  
  def self.log_api_access_time(time=nil) #when starting the app for first time, time may be nil. Also this allow you to check the log time.
    time ? @@last_request_time = time : @@last_request_time 
  end
  
  def self.get_character_id(acct, outlaw_names)
    acct.scope = "eve"
    begin
      temp_coll = acct.characterID(:names => outlaw_names.collect{|n| n[0]}.join(',')).characters
    rescue
      return false
    end
    combine = temp_coll.collect{|t| [t.name,t.characterID]}.zip(outlaw_names.collect{|o| o[1]}).each{|t| t.flatten!}
    #Output=> [["ACID BURNN", "648536349", "20000000.00"], ["Zer0 kooL", "1436418183", "10000000.00"]]
    # [[NAME,CHARACTERID,BOUNTY PLACED]]
    combine.each do |target|
      if target[1] != 0
        WantedToon.make_wanted_toon(target[0],target[1].to_i,target[2].to_i)
      else
        #create sendmail to admin with log of failed name
        return false
      end
    end
  end
  
end