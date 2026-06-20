module EnumHelper
  # Localized label for an enum value.
  # Example: t_enum(:reward, :reward_type, reward.reward_type)
  def t_enum(model, attr, value)
    return if value.blank?

    t("enums.#{model}.#{attr}.#{value}", default: value.to_s.humanize)
  end
end
