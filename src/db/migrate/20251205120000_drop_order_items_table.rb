class DropOrderItemsTable < ActiveRecord::Migration[8.1]
  def change
    drop_table :order_items, if_exists: true
  end
end
