json.extract! cart, :id, :user_id, :status, :created_at, :updated_at
json.url cart_url(cart, format: :json)
