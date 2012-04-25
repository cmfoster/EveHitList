class EveApiChecker
  
  @@last_request_time = Time
  
  #check corporation wallet journal for all refTypeID's of 10(donations) and dated after last donation recieved.
  def self.check_corp_journal_for_new_donations
    acct = eve_api
    begin
      entries = acct.walletjournal.entries
    rescue EAAL::Exception.EveAPIException(500)
      return false
    rescue EAAL::Exception.EveAPIException(904)
      return false
    end
    @@last_request_time ||= acct.request_time.to_time #Set @@last_request_time in case this is the initial launch, which is would be nil.
    all_transfers = entries.collect {
      |e| e.reason.gsub(/[DECS:\s]/, "") if e.refTypeID.to_i == 10 && e.date.to_time > @@last_request_time
    }
    log_api_access_time(acct.request_time.to_time)
    return all_transfers
  end
  
  private
  def self.eve_api
    EAAL::API.new(CORP_USER_ID, CORP_VCODE, "corp")
  end
  
  def log_api_access_time(time=nil)
    time ? @@last_request_time = time : @@last_request_time 
  end
  
end