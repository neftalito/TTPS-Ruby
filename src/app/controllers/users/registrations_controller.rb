class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def update_resource(resource, params)
    clean_params = params.dup
    email_changed = clean_params[:email].present? && clean_params[:email] != resource.email

    # Los cambios sensibles deben validar la contraseña actual.
    return resource.update_with_password(clean_params) if clean_params[:password].present? || email_changed

    clean_params.delete(:password) if clean_params[:password].blank?
    clean_params.delete(:password_confirmation) if clean_params[:password_confirmation].blank?
    clean_params.delete(:current_password)

    resource.update_without_password(clean_params)
  end
end
