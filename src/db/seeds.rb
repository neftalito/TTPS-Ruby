require "faker"
require "pathname"
require "marcel"

puts "Eliminando datos existentes..."
ActiveRecord::Base.connection.disable_referential_integrity do
  SaleItem.unscoped.delete_all
  Sale.unscoped.delete_all
  ActiveStorage::Attachment.where(record_type: "Product").find_each(&:purge)
  Product.unscoped.delete_all
  Category.unscoped.delete_all
  User.unscoped.delete_all
end

puts "Creando usuarios predeterminados..."
users = [
  { email: "empleado@sistema.com", password: "empleado123", role: :employee },
  { email: "manager@sistema.com", password: "manager123", role: :manager },
  { email: "admin@sistema.com", password: "admin123", role: :admin },
  { email: "invitado@sistema.com", password: "invitado123", role: :employee }
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
Faker::UniqueGenerator.clear

puts "Creando generos..."
category_data = [
  { name: "Rock", description: "Clasicos inmortales, riffs poderosos y guitarras distorsionadas." },
  { name: "Pop", description: "Melodias pegajosas y producciones brillantes que marcan tendencias." },
  { name: "Jazz", description: "Improvisacion, elegancia y armonias complejas para disfrutar con calma." },
  { name: "Blues", description: "Voces profundas y guitarras sentimentales cargadas de emocion." },
  { name: "Funk", description: "Ritmos contagiosos y lineas de bajo que invitan a moverse." },
  { name: "Soul", description: "Canciones llenas de sentimiento y poder vocal." },
  { name: "Electronica", description: "Beats modernos, sintetizadores y sonidos experimentales." },
  { name: "Hip Hop", description: "Rimas filosas, bases ritmicas y cultura urbana." },
  { name: "Reggae", description: "Vibras relajadas, mensajes positivos y ritmos caribenos." },
  { name: "Metal", description: "Sonidos pesados, doble bombo y voces contundentes." },
  { name: "Clasica", description: "Obras maestras orquestales e instrumentales que perduran." },
  { name: "Latino", description: "Salsa, bachata y ritmos festivos de toda la region." }
]
categories = category_data.map { |attributes| Category.create!(attributes) }

puts "Creando productos..."
seed_assets_root = Rails.root.join("db", "seed_assets")
asset_path = ->(absolute_path) { Pathname.new(absolute_path).relative_path_from(Rails.root).to_s }
image_library = Dir[seed_assets_root.join("images", "*")].sort.map(&asset_path)
audio_samples = Dir[seed_assets_root.join("audio", "*")].sort.map(&asset_path)

raise "No se encontraron imagenes locales en #{seed_assets_root.join("images")}" if image_library.empty?
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
    published: true,
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
all_users = User.all
raise "No hay usuarios para crear ventas" if all_users.empty?

default_employee = User.find_by!(email: "empleado@sistema.com")
default_manager = User.find_by!(email: "manager@sistema.com")
default_admin = User.find_by!(email: "admin@sistema.com")

report_products = Product.includes(:category).where(published: true).where("stock >= 3").order(:id)
vinyl_products = report_products.select(&:product_type_vinyl?).first(3)
cd_products = report_products.select(&:product_type_cd?).first(3)

if vinyl_products.size >= 2 && cd_products.size >= 2
  puts "Creando ventas demostracion para reportes..."

  demo_sales = [
    {
      user: default_employee,
      buyer_name: "Cliente Reporte 1",
      buyer_email: "reporte1@example.com",
      buyer_dni: "11111111",
      created_at: 45.days.ago.change(hour: 11),
      items: [
        [vinyl_products[0], 2],
        [cd_products[0], 1]
      ]
    },
    {
      user: default_manager,
      buyer_name: "Cliente Reporte 2",
      buyer_email: "reporte2@example.com",
      buyer_dni: "22222222",
      created_at: 18.days.ago.change(hour: 17),
      items: [
        [vinyl_products[1], 1],
        [cd_products[1], 2]
      ]
    },
    {
      user: default_admin,
      buyer_name: "Cliente Reporte 3",
      buyer_email: "reporte3@example.com",
      buyer_dni: "33333333",
      created_at: 6.days.ago.change(hour: 14),
      items: [
        [vinyl_products[0], 1],
        [vinyl_products[1], 1],
        [cd_products[0], 1]
      ]
    },
    {
      user: default_employee,
      buyer_name: "Cliente Cancelado",
      buyer_email: "cancelado@example.com",
      buyer_dni: "44444444",
      created_at: 12.days.ago.change(hour: 9),
      cancelled: true,
      items: [
        [cd_products[1], 2],
        [vinyl_products[0], 1]
      ]
    }
  ]

  demo_sales.each do |sale_data|
    sale = Sale.new(
      user: sale_data[:user],
      buyer_name: sale_data[:buyer_name],
      buyer_email: sale_data[:buyer_email],
      buyer_dni: sale_data[:buyer_dni],
      created_at: sale_data[:created_at],
      updated_at: sale_data[:created_at]
    )

    sale_data[:items].each do |product, quantity|
      sale.sale_items.build(product: product, quantity: quantity, unit_price: product.price)
    end

    sale.save!

    next unless sale_data[:cancelled]

    cancelled_at = sale_data[:created_at] + 2.hours
    sale.cancel!
    sale.update_columns(cancelled_at: cancelled_at, updated_at: cancelled_at)
  end
end

150.times do
  all_products = Product.where(published: true).where("stock > 0").to_a
  available_stock = all_products.index_with(&:stock)
  break if available_stock.empty?

  user = all_users.sample
  created_at = Faker::Time.between(from: 12.months.ago, to: Time.current)

  sale = Sale.new(
    user: user,
    buyer_name: Faker::Name.name,
    buyer_email: Faker::Internet.email,
    buyer_dni: Faker::Number.number(digits: 8),
    created_at: created_at,
    updated_at: created_at
  )

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

  sale.total = sale.sale_items.sum { |item| item.quantity * item.unit_price }
  sale.save!

  next unless rand < 0.10

  cancelled_at = [created_at + 2.hours, Time.current].min
  sale.cancel!
  sale.update_columns(cancelled_at: cancelled_at, updated_at: cancelled_at)
end

puts "Datos de prueba creados exitosamente."
