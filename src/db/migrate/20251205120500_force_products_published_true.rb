class ForceProductsPublishedTrue < ActiveRecord::Migration[8.1]
  def up
    change_column_default :products, :published, from: nil, to: true
    Product.update_all(published: true)
  end

  def down
    change_column_default :products, :published, from: true, to: nil
  end
end
