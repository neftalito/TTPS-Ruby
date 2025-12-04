class RemoveInventoryEnteredAtAndAddReleaseYearToProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :inventory_entered_at, :datetime
    
    add_column :products, :release_year, :integer
    
    add_index :products, :release_year
  end
end