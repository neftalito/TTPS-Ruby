class AddMetadataToProducts < ActiveRecord::Migration[8.1]
  def change
    change_table :products, bulk: true do |t|
      t.string :author
      t.string :product_type, null: false, default: "vinyl"
      t.string :condition, null: false, default: "new"
      t.string :audio_sample_url
      t.datetime :inventory_entered_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :last_modified_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :deactivated_at
    end
  end
end