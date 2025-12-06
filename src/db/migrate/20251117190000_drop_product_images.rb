class DropProductImages < ActiveRecord::Migration[8.1]
  def up
    drop_table :product_images, if_exists: true
  end

  def down
    create_table :product_images do |t|
      t.string :alt
      t.references :product, null: false, foreign_key: true
      t.string :url

      t.timestamps
    end
  end
end