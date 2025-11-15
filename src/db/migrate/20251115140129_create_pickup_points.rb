class CreatePickupPoints < ActiveRecord::Migration[8.1]
  def change
    create_table :pickup_points do |t|
      t.string :name
      t.string :address
      t.string :city
      t.string :province
      t.boolean :enabled

      t.timestamps
    end
  end
end
