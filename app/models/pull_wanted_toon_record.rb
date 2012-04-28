class PullWantedToonRecord 
  require 'open-uri'
  #TODO, Pull corp/alliance record. Also pull final blow killer name.
  
  @@battle_clinic = "http://eve.battleclinic.com"
  @@killboard = "/killboard/combat_record.php?type=player&name="
  
  def self.find_new_bc_records(target)
    stats_page = Nokogiri::HTML(open(@@battle_clinic+@@killboard+target.name.gsub(/\s/, "%20")+"#losses"))
    begin
      tbody = stats_page.xpath("//div[@id = 'lossContainer']/table[@class = 'contentListTable']/tbody")
      #Collect arrays with URL,ShipType,SystemName and strip down system name to only letters
      uri_ship_system = tbody.first.children.first(3).collect{
	|t| t.xpath("td[1]").children.children.first.values + [t.xpath("td[5]").children.text.gsub(/[^A-Za-z]/, "")] +
             [DateTime.strptime(t.xpath("td[6]").children.text,"%m/%d/%y %H:%M:%S").change(:offset => "+0000").to_s]
      } #=> ["/killboard/killmail.php?id=14625287", "Dominix", "Oijanen", "Time"]
      
      uri_ship_system_iskdrop_ttliskloss_verified = uri_ship_system.collect{|t| t + get_ship_loss_records(t[0])}
      #=> [[URI, SHIP TYPE, SYSTEM, TIME, ISK DESTROYED, ISK DROPPED, VERIFIED(BOOL)]]
    rescue
      #Send Mailer to Admin
    return false
    end
    update_toons = uri_ship_system_iskdrop_ttliskloss_verified.collect{|v| v if v.last == 1}.delete_if{|n| n.nil?}
    target.update_toon_create_ship_record(update_toons) if !update_toons.empty?
  end
  
  def self.get_ship_loss_records(uri)
    killmail_page = Nokogiri::HTML(open(@@battle_clinic+uri))
    begin
      isk = killmail_page.xpath("//div[@id = 'fitting']/div[@class = 'inner']/table").first.children
      killmail_page.xpath("//div[@id = 'mailSource']/table").first.xpath("tr/td").first.children.last.values[1] == "API Verified mail" ? 
      verified = 1 : verified = 0
     return isk[1].children[2].text.gsub(',',"").to_i, isk[2].children[2].text.gsub(',',"").to_i, verified
     #=> [isk destroyed, isk dropped,Verified(Bool)]
    rescue
      #Send Mailer to Admin
    end
  end
end