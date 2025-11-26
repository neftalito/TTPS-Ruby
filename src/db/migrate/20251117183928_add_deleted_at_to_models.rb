class AddDeletedAtToModels < ActiveRecord::Migration[8.1]
  TABLES = %i[
    products
    users
  ].freeze

  def change
    TABLES.each do |table_name|
      add_column table_name, :deleted_at, :datetime
      add_index table_name, :deleted_at
    end
  end
end
