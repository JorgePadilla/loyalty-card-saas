namespace :platform do
  desc "Create/update a platform (SaaS owner) admin. Usage: rails platform:create_admin EMAIL=you@x.com NAME=\"Jorge\" (you'll be prompted for the password)"
  task create_admin: :environment do
    require "io/console"

    email = ENV["EMAIL"].to_s.strip
    name = ENV["NAME"].presence || "Platform Admin"
    abort("EMAIL is required") if email.blank?

    # Prefer a hidden interactive prompt so the password never lands in shell
    # history or logs; fall back to PASSWORD env if there is no TTY.
    password = ENV["PASSWORD"].presence
    if password.nil?
      if $stdin.respond_to?(:getpass) && $stdin.tty?
        password = $stdin.getpass("Password: ")
        confirm  = $stdin.getpass("Confirm password: ")
        abort("Passwords did not match") unless password == confirm
      else
        abort("No TTY for a password prompt — pass PASSWORD=... on the command line")
      end
    end
    abort("Password can't be blank") if password.to_s.length < 8

    admin = PlatformAdmin.find_or_initialize_by(email_address: email)
    admin.name = name
    admin.password = password
    admin.save!

    puts "✅ Platform admin ready: #{admin.email_address}"
  end
end
