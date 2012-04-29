class AddLostToToWtShip < ActiveRecord::Migration
  def change
    add_column :wt_ships, :lost_to, :string
  end
end
