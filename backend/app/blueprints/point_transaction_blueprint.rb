class PointTransactionBlueprint < Blueprinter::Base
  identifier :id
  fields :kind, :points, :description, :created_at

  association :staff, blueprint: UserBlueprint, if: ->(_field, pt, _opts) { pt.staff.present? }
end
