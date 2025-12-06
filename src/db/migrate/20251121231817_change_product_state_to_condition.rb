class ChangeProductStateToCondition < ActiveRecord::Migration[8.1]
  def up
    # Migrar datos existentes de product_state a condition
    if column_exists?(:products, :product_state)
      Product.reset_column_information
      Product.find_each do |product|
        if product.product_state == 0
          product.update_column(:condition, "new")
        elsif product.product_state == 1
          product.update_column(:condition, "used")
        end
      end
      
      # Eliminar la columna product_state
      remove_column :products, :product_state
    end
  end

  def down
    unless column_exists?(:products, :product_state)
      add_column :products, :product_state, :integer
      
      Product.reset_column_information
      Product.find_each do |product|
        if product.condition == "new"
          product.update_column(:product_state, 0)
        elsif product.condition == "used"
          product.update_column(:product_state, 1)
        end
      end
    end
  end
end