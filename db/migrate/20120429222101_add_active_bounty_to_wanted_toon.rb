class AddActiveBountyToWantedToon < ActiveRecord::Migration
  def change
    add_column :wanted_toons, :active_bounty, :boolean
  end
end
