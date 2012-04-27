class AddEveTimeDateToWtShips < ActiveRecord::Migration
  def change
    add_column :wt_ships, :eve_time_date, :datetime
  end
end
