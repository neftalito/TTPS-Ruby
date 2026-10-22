class Users::RegistrationsController < Devise::RegistrationsController
  layout "backstore", only: %i[edit update]

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    update_params = account_update_params
    sensitive_change = sensitive_account_change?(resource, update_params)

    resource_updated = update_resource(resource, update_params)
    yield resource if block_given?

    if resource_updated
      if sensitive_change
        sign_out(resource_name)
        flash[:notice] = I18n.t("devise.registrations.updated_but_not_signed_in")
        redirect_to new_user_session_path, status: Devise.responder.redirect_status
      else
        set_flash_message_for_update(resource, prev_unconfirmed_email)
        respond_with resource, location: after_update_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def after_update_path_for(_resource)
    edit_user_registration_path
  end

  protected

  def update_resource(resource, params)
    clean_params = params.dup

    # Los cambios sensibles deben validar la contraseña actual.
    return resource.update_with_password(clean_params) if sensitive_account_change?(resource, clean_params)

    clean_params.delete(:password) if clean_params[:password].blank?
    clean_params.delete(:password_confirmation) if clean_params[:password_confirmation].blank?
    clean_params.delete(:current_password)

    resource.update_without_password(clean_params)
  end

  private

  def sensitive_account_change?(resource, params)
    password_changed = params[:password].present?
    email_changed = params[:email].present? && params[:email] != resource.email

    password_changed || email_changed
  end
end
