class PullWantedToonRecord
  
  @@battle_clinic = "http://eve.battleclinic.com/"
  @@killboard = "killboard/combat_record.php?type=player&name="
  
  def self.find_new_bc_records(target)
    stats_page = Nokogiri::HTML(open(@@battle_clinic+@@killboard+target.name))
    begin
      tbody = stats_page.xpath("//div[@id = 'lossContainer']/table[@class = 'contentListTable']/tbody").first(3)
      uri_and_ship_types = tbody.collect{|t| t.xpath("td[1]").children.children.first.values}
      s_systems = tbody.collect{|t| t.xpath("td[5]").children.text}
    rescue
      #Send Mailer to Admin
      return false
    end
  end
end