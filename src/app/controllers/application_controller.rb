class ApplicationController < ActionController::Base
  include CanCan::ControllerAdditions

  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :set_locale

  # Solo pedimos login en el backstore
  before_action :authenticate_user!, unless: :public_controller?

  # Necesario para permitir parametros adicionales de Devise
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to backstore_root_path, alert: exception.message }
      format.json { render json: { error: exception.message }, status: :forbidden }
    end
  end

  def after_sign_in_path_for(_resource)
    backstore_root_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  protected

  # Parametros permitidos para Devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  private

  def set_locale
    locale = normalized_locale(params[:locale].presence || current_user&.locale.presence || session[:locale].presence)

    I18n.locale = locale
    session[:locale] = locale.to_s
  end

  def normalized_locale(locale)
    locale = locale.to_s

    return I18n.default_locale if locale.blank?
    return locale.to_sym if I18n.available_locales.map(&:to_s).include?(locale)

    I18n.default_locale
  end

  # Detecta que controladores deben ser publicos
  def public_controller?
    is_a?(Storefront::BaseController) || devise_controller?
  end
end
