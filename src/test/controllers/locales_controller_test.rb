require "test_helper"

class LocalesControllerTest < ActionDispatch::IntegrationTest
  test "updates locale for guests through the rendered storefront" do
    patch locale_url, params: { locale: "en", return_to: root_path }

    assert_redirected_to root_url

    follow_redirect!

    assert_response :success
    assert_includes response.body, I18n.t("common.navigation.home", locale: :en)
    assert_includes response.body, I18n.t("common.navigation.catalog", locale: :en)
  end

  test "updates locale for signed in users and persists it" do
    user = users(:employee)
    sign_in user

    patch locale_url, params: { locale: "en", return_to: backstore_root_path }

    assert_redirected_to backstore_root_url
    assert_equal "en", user.reload.locale

    follow_redirect!

    assert_response :success
    assert_includes response.body, I18n.t("layouts.backstore.heading", locale: :en)
  end

  test "falls back to the default locale when an unsupported value is submitted" do
    patch locale_url, params: { locale: "pt", return_to: root_path }

    assert_redirected_to root_url

    follow_redirect!

    assert_response :success
    assert_includes response.body, I18n.t("common.navigation.home", locale: I18n.default_locale)
    assert_includes response.body, I18n.t("common.navigation.catalog", locale: I18n.default_locale)
  end
end
