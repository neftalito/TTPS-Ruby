class ApplicationController < ActionController::Base
  include CanCan::ControllerAdditions

  allow_browser versions: :modern
  stale_when_importmap_changes

  # Solo pedimos login en el backstore
  before_action :authenticate_user!, unless: :public_controller?

  # Necesario para permitir parámetros adicionales de Devise
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_path, alert: exception.message }
      format.json { render json: { error: exception.message }, status: :forbidden }
    end
  end

  def after_sign_in_path_for(resource)
    backstore_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  protected

  # Parámetros permitidos para Devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  private

  # Detecta qué controladores deben ser públicos
  def public_controller?
    is_a?(Storefront::BaseController) || devise_controller?
  end
end
