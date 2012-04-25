class CreateWantedToons < ActiveRecord::Migration
  def change
    create_table :wanted_toons do |t|
      t.integer :character_id
      t.string :name
      t.integer :bounty

      t.timestamps
    end
  end
end
