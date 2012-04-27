class CreateWtShips < ActiveRecord::Migration
  def change
    create_table :wt_ships do |t|
      t.string :lossurl
      t.string :ship_type
      t.integer :isk_dropped
      t.integer :isk_destroyed
      t.integer :payout_amt
      t.integer :wanted_toon_id
      t.string :solar_system

      t.timestamps
    end
  end
end
