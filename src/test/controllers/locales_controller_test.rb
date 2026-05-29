require "test_helper"

class LocalesControllerTest < ActionDispatch::IntegrationTest
  test "updates locale in session for guests" do
    patch locale_url, params: { locale: "en", return_to: storefront_products_path }

    assert_redirected_to storefront_products_url
    assert_equal "en", session[:locale]
  end

  test "updates locale for signed in users" do
    user = users(:employee)
    sign_in user

    patch locale_url, params: { locale: "en", return_to: backstore_root_path }

    assert_redirected_to backstore_root_url
    assert_equal "en", session[:locale]
    assert_equal "en", user.reload.locale
  end

  test "falls back to default locale when an unsupported value is submitted" do
    patch locale_url, params: { locale: "pt", return_to: root_path }

    assert_redirected_to root_url
    assert_equal I18n.default_locale.to_s, session[:locale]
  end
end
