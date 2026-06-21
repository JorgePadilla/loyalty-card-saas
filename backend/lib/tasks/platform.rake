namespace :platform do
  desc "Create/update a platform (SaaS owner) admin: rails platform:create_admin EMAIL=.. PASSWORD=.. NAME=.."
  task create_admin: :environment do
    email = ENV["EMAIL"].to_s.strip
    password = ENV["PASSWORD"].to_s
    name = ENV["NAME"].presence || "Platform Admin"

    abort("EMAIL and PASSWORD are required") if email.blank? || password.blank?

    admin = PlatformAdmin.find_or_initialize_by(email_address: email)
    admin.name = name
    admin.password = password
    admin.save!

    puts "✅ Platform admin ready: #{admin.email_address}"
  end
end
