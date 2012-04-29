class CreateEdenHeros < ActiveRecord::Migration
  def change
    create_table :eden_heros do |t|
      t.string :name
      t.integer :character_id
      t.integer :earned_bounty_amt
      t.string :killuri

      t.timestamps
    end
  end
end
