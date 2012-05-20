class PullWantedToonRecord 
  require 'open-uri'
  #TODO, Pull corp/alliance record. Also pull final blow killer name.
  
  @@battle_clinic = "http://eve.battleclinic.com"
  @@killboard = "/killboard/combat_record.php?type=player&name="
  @@CORP_USER_ID = "874265"
  @@CORP_VCODE = "truf6sOdsU3XHAwRcB0Y53l8fvzsVqlu8eRGTECb6zioTpaYWUzaCxGJXPxogplT"
  
  def self.start_process(target_id)
    Resque.enqueue(GatherTargetRecord, target_id)
  end
  
  def self.find_new_bc_records(target) #TODO, assign each call to pull records to its own worker process to run in the background. 
    counter = 0 #variable set to retry pulling killmail record 3 times. see line 24.
    begin
      stats_page = Nokogiri::HTML(open(@@battle_clinic+@@killboard+target.name.gsub(/\s/, "%20")+"#losses"))
      tbody = stats_page.xpath("//div[@id = 'lossContainer']/table[@class = 'contentListTable']/tbody")
    
      #Collect arrays with URL,ShipType,SystemName and strip down system name to only letters
      uri_ship_system = tbody.first.children.first(5).collect{
        |t| t.xpath("td[1]").children.children.first.values + [t.xpath("td[5]").children.text.gsub(/[^A-Za-z]/, "")] +
             [DateTime.strptime(t.xpath("td[6]").children.text,"%m/%d/%y %H:%M:%S").change(:offset => "+0000").to_s]
        } #=> ["/killboard/killmail.php?id=14625287", "Dominix", "Oijanen", "Time"]
      
      uri_ship_system_iskdrop_ttliskloss_heroname_verified = uri_ship_system.collect{|t| [t + [get_ship_loss_records(t[0])]].flatten} #passing killmail URI to get_ship_loss_records
      #=> [[URI, SHIP TYPE, SYSTEM, TIME, ISK DESTROYED, ISK DROPPED, Hero's Name, Hero's Character ID, VERIFIED(BOOL)]]
      update_toons = uri_ship_system_iskdrop_ttliskloss_heroname_verified.collect{|v| v if v.last == 1}.delete_if{|n| n.nil?}
      target.update_toon_create_ship_record(update_toons) if !update_toons.empty? #sends in the array from uri_ship_system_iskdrop_ttliskloss_heroname_verified
    rescue EOFError
      #setup a log file on the server to recieve these error types
      if counter < 3
        counter += 1
        #retrying
        sleep(1200) if Rails.env.production? #makes the retry sleep for 20 Minutes before retrying. Can take up to 1 full hour to cycle. Only in production
        retry
      else
        #send Admin Email to update manually and inspect error
        AdminMailer.error_mail(EOFError.backtrace).deliver
        counter = 0
      end
    end
  end
  
  def self.get_ship_loss_records(uri)
    killmail_page = Nokogiri::HTML(open(@@battle_clinic+uri))
      isk = killmail_page.xpath("//div[@id = 'fitting']/div[@class = 'inner']/table").first.children
      killmail_page.xpath("//div[@id = 'mailSource']/table").first.xpath("tr/td").first.children.last.values[1] == "API Verified mail" ? #=> CONT' NEXT LINE
      verified = 1 : verified = 0
      hero_name = killmail_page.xpath("//div[@id = 'pilotFinalBlow']/table").children.first.child.children[1].values.last #parse final blow character's name
      hero_character_id = EAAL::API.new(@@CORP_USER_ID, @@CORP_VCODE, "eve").characterID(:names => hero_name).characters.first.characterID
     return isk[1].children[2].text.gsub(',',"").to_i, isk[2].children[2].text.gsub(',',"").to_i, hero_name, hero_character_id.to_i, verified
     #=> [isk destroyed, isk dropped, Hero's Name, Hero's Character ID, Verified(Bool)]
  end
  
  # NEED TO FIX EAAL GEM, GETTING "allianceID= NO VALID METHOD" FROM EAAL.  characterInfo
  # def self.get_killer_of_wanted_toon(hero_name)
  #   api = EAAL::API.new(CORP_USER_ID, CORP_VCODE, "eve")
  #   hero_id = api.character_id(:names => hero_name).characters.first.characterID
  #   if hero_id
  #     api.chracterInfo(:characterID => hero_id)
  #   else
  #     return true
  #   end
  # end
end