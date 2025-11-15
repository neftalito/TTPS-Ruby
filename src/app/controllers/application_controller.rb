class ApplicationController < ActionController::Base
  include CanCan::ControllerAdditions

  allow_browser versions: :modern
  stale_when_importmap_changes

  # Solo pedimos login en el backstore
  before_action :authenticate_user!, unless: :public_controller?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_path, alert: exception.message }
      format.json { render json: { error: exception.message }, status: :forbidden }
    end
  end

  protected

  # No dejar que Devise permita editar/crear roles
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name]) # TODO: Evaluar qué puede cambiar un usuario de sí mismo
  end

  private

  # Detecta qué controladores deben ser públicos
  def public_controller?
    is_a?(Storefront::BaseController) || devise_controller?
  end
end
