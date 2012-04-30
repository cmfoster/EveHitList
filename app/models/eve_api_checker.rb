class EveApiChecker 
  
  @@last_request_time = nil
  
  #check corporation wallet journal for all refTypeID's of 10(donations) and dated after last donation recieved.
  def self.check_corp_journal_for_new_donations(test_time=nil)
    acct = eve_api("corp")
    begin
      wallet = acct.walletjournal
      entries = wallet.entries
    rescue EAAL::Exception.EveAPIException(500)
      return true
    rescue EAAL::Exception.EveAPIException(904)
      return true
    end
    @@last_request_time ||= wallet.request_time.to_time #Set @@last_request_time in case this is the initial launch, which would be nil.
    outlaw_name_or_charids = entries.collect {
      |e| [e.reason.gsub(/[DECS:'\n]/, "").gsub(/^\s/,""), e.amount] if e.refTypeID.to_i == 10 && e.date.to_time > (test_time || @@last_request_time.to_time)
      }
  # return outlaw_name_or_charids unless test_time.nil?
    outlaw_name_or_charids.delete_if {|t| t.nil?}
    log_api_access_time(wallet.request_time.to_time)
    get_character_id(acct, outlaw_name_or_charids) if !outlaw_name_or_charids.empty?
  end
  
  def self.eve_api(scope_opt)
    EAAL::API.new(CORP_USER_ID, CORP_VCODE, scope_opt)
  end
  
  def self.log_api_access_time(time=nil) #when starting the app for first time, time may be nil. Also this allow you to check the log time.
    time ? @@last_request_time = time : @@last_request_time 
  end
  
  def self.get_character_id(acct, outlaw_name_or_charids) #TODO CREATE A NEW API CALL TO COLLECT "characterInfo" FOR EACH ID. RUN A .COLLECT{|A| EAAL.CHARACTERINFO *}
    acct = eve_api("eve") #Not really necessary but kept here anyway.
    outlaws_with_ids = outlaw_name_or_charids.collect{|c| c if is_int(c[0])}.delete_if{|g| g.nil?}
    outlaws_with_names = outlaw_name_or_charids.collect{|c| c if !is_int(c[0])}.delete_if{|g| g.nil?}
    get_character_name(acct, outlaws_with_ids) if !outlaws_with_ids.empty?
    begin
      #submit an array of only the characters with names
      temp_coll_name_id = acct.characterID(:names =>outlaws_with_names.collect{|n| n[0]}.join(',')).characters
      combine = temp_coll_name_id.collect{|t| [t.name,t.characterID]}.zip(outlaws_with_names.collect{|o| o[1]}).each{|t| t.flatten!}
      # [[NAME,CHARACTERID,BOUNTY PLACED]]
      combine.each do |target|
        if target[1] != 0
          corp_alliance = get_char_corp_alliance(target[1]) || ["Unknown","Unknown"] #Start Getting CharacterInfo
          WantedToon.make_wanted_toon(target[0],target[1].to_i,target[2].to_i,corp_alliance[0],corp_alliance[1])
          #Sending in => [NAME,CHARACTERID,BOUNTY PLACED,CORPORATION,ALLIANCE]
        end
      end
    rescue
      #create sendmail to admin with log of failed name
      return false
    end
  end
  
  def self.get_char_corp_alliance(char_id)
    acct = EAAL::API.new("", "", "eve")
    counter = 0
    #Put this begin/rescue process in a worker thread
    begin
      char_info = acct.characterInfo(:characterID => char_id)
      corp_alliance = [char_info.corporation, char_info.alliance]
      return corp_alliance
    rescue
      if counter < 3
        counter += 1
        sleep(1200) if Rails.env.production? #wait 20minutes before next pull if failure
        retry
      else
        counter = 0
      end
      #send Admin Email
      return ["Unknown","Unknown"]
    end
  end
  
  def self.get_character_name(acct, outlaws_with_ids)
    counter = 0
    begin
    	acct.scope = "eve"
    	target_names = acct.charactername(:ids => outlaws_with_ids.collect{|c| c[0].gsub("'", "")}.join(',')).characters
    rescue
      if counter < 3
        counter += 1
        sleep(1200) if Rails.env.production? #wait 20minutes before next pull if failure
        retry
      else
        counter = 0
      end
    end
    combine = target_names.collect{|t| t.name}.zip(outlaws_with_ids.collect{|o| [o[0],o[1]]}).each{|f| f.flatten!}
    combine.each do |target|
      if target[0].size > 0
        corp_alliance = get_char_corp_alliance(target[1])  #Start Getting CharacterInfo
	      WantedToon.make_wanted_toon(target[0], target[1].to_i, target[2].to_i,corp_alliance[0],corp_alliance[1]) #=> [NAME,CHARACTERID,BOUNTY,CORPORATION,ALLIANCE]
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