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
    outlaw_name_or_charids = entries.collect {
      |e| [e.reason.gsub(/[DECS:'\n]/, "").gsub(/^\s/,""), e.amount] if e.refTypeID.to_i == 10 && e.date.to_time > (test_time || @@last_request_time)
      }
  # return outlaw_name_or_charids unless test_time.nil?
    outlaw_name_or_charids.delete_if {|t| t.nil?}
    log_api_access_time(wallet.request_time.to_time)
    get_character_id(acct, outlaw_name_or_charids) if !outlaw_name_or_charids.empty?
  end
  
  def self.eve_api
    EAAL::API.new(CORP_USER_ID, CORP_VCODE, "corp")
  end
  
  def self.log_api_access_time(time=nil) #when starting the app for first time, time may be nil. Also this allow you to check the log time.
    time ? @@last_request_time = time : @@last_request_time 
  end
  
  def self.get_character_id(acct, outlaw_name_or_charids)
    acct.scope = "eve"
    outlaws_with_ids = outlaw_name_or_charids.collect{|c| c if is_int(c[0])}.delete_if{|g| g.nil?}
    outlaws_with_names = outlaw_name_or_charids.collect{|c| c if !is_int(c[0])}.delete_if{|g| g.nil?}
    get_character_name(acct, outlaws_with_ids) if !outlaws_with_ids.empty?
    begin
      #submit an array of only the characters with names
      temp_coll = acct.characterID(:names =>outlaws_with_names.collect{|n| n[0]}.join(',')).characters
    rescue
      return false
    end
    combine = temp_coll.collect{|t| [t.name,t.characterID]}.zip(outlaws_with_names.collect{|o| o[1]}).each{|t| t.flatten!}
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
  
  def self.get_character_name(acct, outlaws_with_ids)
    begin
	acct.scope = "eve"
	target_names = acct.charactername(:ids => outlaws_with_ids.collect{|c| c[0].gsub("'", "")}.join(',')).characters
	p target_names
	p outlaws_with_ids
    rescue
	return false
    end
    combine = target_names.collect{|t| t.name}.zip(outlaws_with_ids.collect{|o| [o[0],o[1]]}).each{|f| f.flatten!}
    combine.each do |target|
      if target[0].size > 0
	WantedToon.make_wanted_toon(target[0], target[1].to_i, target[2].to_i)
      else
	#create sendmail to admin with log of failed name
	return false
      end
    end
  end
  
  def self.is_int(string=nil)
      !!(string =~ /^[-+]?[0-9]+$/)
  end

end