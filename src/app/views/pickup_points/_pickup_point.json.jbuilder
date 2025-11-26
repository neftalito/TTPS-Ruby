json.extract! pickup_point, :id, :name, :address, :city, :province, :enabled, :created_at, :updated_at
json.url pickup_point_url(pickup_point, format: :json)
