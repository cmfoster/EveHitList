class AddCorporationAndAllianceToWantedToon < ActiveRecord::Migration
  def change
    add_column :wanted_toons, :corporation, :string
    add_column :wanted_toons, :alliance, :string
  end
end
