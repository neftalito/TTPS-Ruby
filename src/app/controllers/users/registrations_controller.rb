class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def update_resource(resource, params)
    clean_params = params.dup

    # Quitar contraseña si está en blanco
    if clean_params[:password].blank?
      clean_params.delete(:password)
      clean_params.delete(:password_confirmation)
      clean_params.delete(:current_password)
      return resource.update_without_password(clean_params)
    end

    # Si está cambiando contraseña
    resource.update_with_password(clean_params)
  end
end
