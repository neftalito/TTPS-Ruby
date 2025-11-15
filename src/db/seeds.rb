# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Creando usuarios"

User.destroy_all

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

