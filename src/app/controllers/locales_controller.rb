class LocalesController < ApplicationController
  skip_before_action :authenticate_user!, only: :update

  def update
    locale = normalized_locale(params[:locale])

    session[:locale] = locale.to_s
    current_user&.update(locale: locale.to_s) if current_user&.locale != locale.to_s

    redirect_to safe_return_path || root_path, allow_other_host: false
  end

  private

  def safe_return_path
    path = params[:return_to].presence

    return path if path&.start_with?("/") && !path.start_with?("//")

    return if request.referer.blank?

    uri = URI.parse(request.referer)
    return unless uri.host == request.host && uri.port == request.port

    [uri.path.presence || "/", uri.query.present? ? "?#{uri.query}" : nil].compact.join
  rescue URI::InvalidURIError
    nil
  end
end
