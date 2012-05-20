class AddPaidToEdenHeros < ActiveRecord::Migration
  def change
    add_column :eden_heros, :paid, :boolean
  end
end
