class CreateSales < ActiveRecord::Migration[8.1]
  def change
    create_table :sales do |t|
      t.references :user, null: false, foreign_key: true
      t.string :buyer_name
      t.string :buyer_email
      t.string :buyer_dni
      t.decimal :total
      t.datetime :cancelled_at

      t.timestamps
    end
  end
end
