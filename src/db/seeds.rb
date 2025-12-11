require "faker"
require "pathname"
require "marcel"

puts "Eliminando datos existentes..."
ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = OFF")
SaleItem.delete_all
Sale.delete_all
ActiveStorage::Attachment.where(record_type: "Product").find_each(&:purge)
Product.delete_all
Category.delete_all
User.delete_all

ActiveRecord::Base.connection.execute("PRAGMA foreign_keys = ON")
puts "Creando usuarios predeterminados..."
users = [
  {
    email: "empleado@sistema.com",
    password: "empleado123",
    role: :employee
  },
  {
    email: "manager@sistema.com",
    password: "manager123",
    role: :manager
  },
  {
    email: "admin@sistema.com",
    password: "admin123",
    role: :admin
  },
  {
    email: "invitado@sistema.com",
    password: "invitado123",
    role: :employee
  }
]

users.each do |attrs|
  User.create!(attrs)
end

puts "Creando usuarios con faker..."
roles = User.roles.keys
100.times do
  User.create!(
    email: Faker::Internet.unique.email,
    password: "usuario123",
    role: roles.sample
  )
end
Faker::UniqueGenerator.clear # Resetea los generadores únicos para próximos usos.


puts "Creando categorías..."
category_data = [
  { name: "Rock", description: "Clásicos inmortales, riffs poderosos y guitarras distorsionadas." },
  { name: "Pop", description: "Melodías pegajosas y producciones brillantes que marcan tendencias." },
  { name: "Jazz", description: "Improvisación, elegancia y armonías complejas para disfrutar con calma." },
  { name: "Blues", description: "Voces profundas y guitarras sentimentales cargadas de emoción." },
  { name: "Funk", description: "Ritmos contagiosos y líneas de bajo que invitan a moverse." },
  { name: "Soul", description: "Canciones llenas de sentimiento y poder vocal." },
  { name: "Electrónica", description: "Beats modernos, sintetizadores y sonidos experimentales." },
  { name: "Hip Hop", description: "Rimas filosas, bases rítmicas y cultura urbana." },
  { name: "Reggae", description: "Vibras relajadas, mensajes positivos y ritmos caribeños." },
  { name: "Metal", description: "Sonidos pesados, doble bombo y voces contundentes." },
  { name: "Clásica", description: "Obras maestras orquestales e instrumentales que perduran." },
  { name: "Latino", description: "Salsa, bachata y ritmos festivos de toda la región." }
]
categories = category_data.map do |attributes|
  Category.create!(attributes)
end

puts "Creando productos..."
seed_assets_root = Rails.root.join("db", "seed_assets")
asset_path = ->(absolute_path) { Pathname.new(absolute_path).relative_path_from(Rails.root).to_s }
image_library = Dir[seed_assets_root.join("images", "*")].sort.map(&asset_path)
audio_samples = Dir[seed_assets_root.join("audio", "*")].sort.map(&asset_path)

raise "No se encontraron imágenes locales en #{seed_assets_root.join("images")}" if image_library.empty?
raise "No se encontraron samples locales en #{seed_assets_root.join("audio")}" if audio_samples.empty?

product_types = Product.product_types.keys
conditions = Product.conditions.keys

150.times do
  category = categories.sample
  condition = conditions.sample
  product_type = product_types.sample
  release_year = Faker::Number.between(from: 1950, to: Date.current.year)
  base_time = Faker::Time.between(from: 18.months.ago, to: 3.months.ago)
  last_modified_at = Faker::Time.between(from: base_time, to: Time.current)
  deactivated_at = rand < 0.15 ? Faker::Time.between(from: last_modified_at, to: Time.current) : nil

  selected_audio_path = condition == "used" ? Rails.root.join(audio_samples.sample) : nil

  product = Product.new(
    name: Faker::Music.album,
    description: Faker::Lorem.paragraph(sentence_count: 4),
    author: Faker::Music.band,
    price: Faker::Commerce.price(range: 12.0..80.0),
    stock: Faker::Number.between(from: 0, to: 75),
    category: category,
    product_type: product_type,
    condition: condition,
    audio_sample_url: condition == "used" ? audio_samples.sample : nil,
    release_year: release_year,
    last_modified_at: last_modified_at,
    deactivated_at: deactivated_at,
    published: deactivated_at.nil?,
    created_at: base_time,
    updated_at: last_modified_at
  )

  rand(1..3).times do
    absolute_path = Rails.root.join(image_library.sample)

    product.images.attach(
      io: File.open(absolute_path),
      filename: File.basename(absolute_path),
      content_type: Marcel::MimeType.for(Pathname.new(absolute_path))
    )
  end

  if selected_audio_path
    product.audio.attach(
      io: File.open(selected_audio_path),
      filename: File.basename(selected_audio_path),
      content_type: Marcel::MimeType.for(Pathname.new(selected_audio_path))
    )
  end

  product.save!
end
puts "Creando ventas..."

# Tomamos usuarios existentes
all_users = User.all

raise "No hay usuarios para crear ventas" if all_users.empty?

150.times do
  # Volvemos a consultar productos en cada vuelta por si se agotó el stock
  all_products = Product.where(published: true).where("stock > 0").to_a
  available_stock = all_products.index_with(&:stock)

  break if available_stock.empty?
  
  user = all_users.sample
  created_at = Faker::Time.between(from: 12.months.ago, to: Time.current)
  cancelled_at = rand < 0.10 ? Faker::Time.between(from: created_at, to: Time.current) : nil

  sale = Sale.new(
    user: user,
    buyer_name: Faker::Name.name,
    buyer_email: Faker::Internet.email,
    buyer_dni: Faker::Number.number(digits: 8),
    cancelled_at: cancelled_at,
    created_at: created_at,
    updated_at: created_at
  )

  # SaleItems
  rand(1..5).times do
    eligible_products = available_stock.select { |_, stock| stock > 0 }.keys
    break if eligible_products.empty?

    product = eligible_products.sample
    max_quantity = [available_stock[product], 3].min
    next if max_quantity < 1

    quantity = rand(1..max_quantity)

    available_stock[product] -= quantity

    sale.sale_items.build(
      product: product,
      quantity: quantity,
      unit_price: product.price
    )
  end

  next if sale.sale_items.empty?

  # Calcular total REAL de la venta
  total = sale.sale_items.sum { |item| item.quantity * item.unit_price }
  sale.total = total

  # Guardar
  sale.save!
end
puts "Datos de prueba creados exitosamente."