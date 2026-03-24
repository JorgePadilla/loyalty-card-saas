class UserBlueprint < Blueprinter::Base
  identifier :id
  fields :email_address, :first_name, :last_name, :phone, :role, :created_at

  field :full_name do |user|
    user.full_name
  end
end
