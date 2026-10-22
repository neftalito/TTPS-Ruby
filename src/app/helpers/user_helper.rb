module UserHelper
  def translated_role(role)
    I18n.t("roles.#{role}", default: role.to_s.humanize)
  end

  def assignable_roles_for(current_user)
    return [] unless current_user

    if current_user.admin?
      User.roles.keys
    elsif current_user.manager?
      %w[manager employee]
    else
      []
    end
  end
end
