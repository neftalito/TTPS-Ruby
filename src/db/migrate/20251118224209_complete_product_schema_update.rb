class CompleteProductSchemaUpdate < ActiveRecord::Migration[8.1]
  def change
    
    # 1. Columna ENUM (product_state)
    add_column :products, :product_state, :integer, default: 0, null: false 
  
  
    add_column :products, :audio_file, :string # Para el audio opcional (ruta/URL)
  end
end