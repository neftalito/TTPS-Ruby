require "faker"
require "pathname"
require "marcel"

puts "Eliminando datos existentes..."
SaleItem.delete_all
Sale.delete_all
ActiveStorage::Attachment.where(record_type: "Product").find_each(&:purge)
Product.delete_all
Category.delete_all
User.delete_all

puts "Creando usuarios predeterminados..."
users = [
  {
    email: "empleado@sistema.com",
    password: "empleado123",
    role: :employee
  },
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
  inventory_entered_at = Faker::Time.between(from: 18.months.ago, to: 3.months.ago)
  last_modified_at = Faker::Time.between(from: inventory_entered_at, to: Time.current)
  deactivated_at = rand < 0.15 ? Faker::Time.between(from: last_modified_at, to: Time.current) : nil

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
    inventory_entered_at: inventory_entered_at,
    last_modified_at: last_modified_at,
    deactivated_at: deactivated_at,
    published: deactivated_at.nil?,
    created_at: inventory_entered_at,
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

  product.save!
end
puts "Creando ventas..."

# Tomamos usuarios y productos existentes
all_users = User.all
all_products = Product.where(published: true)

raise "No hay usuarios para crear ventas" if all_users.empty?
raise "No hay productos publicados para ventas" if all_products.empty?


150.times do
  user = all_users.sample

  created_at = Faker::Time.between(from: 12.months.ago, to: Time.current)

  cancelled_at = rand < 0.10 ? Faker::Time.between(from: created_at, to: Time.current) : nil

  sale = Sale.create!(
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
    product = all_products.sample
    quantity = rand(1..3)
    unit_price = product.price

    sale.sale_items.create!(
      product: product,
      quantity: quantity,
      unit_price: unit_price
    )
  end

  # Calcular total REAL de la venta
  total = sale.sale_items.sum("quantity * unit_price")

  sale.update_column(:total, total)
end

puts "Seed completado."
