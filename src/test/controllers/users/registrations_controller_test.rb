require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:employee)
    sign_in @user
  end

  test "shows the profile edit page" do
    get edit_user_registration_url

    assert_response :success
  end

  test "requires the current password to change the email" do
    patch user_registration_url, params: {
      user: {
        email: "nuevo_email@example.com",
        current_password: ""
      }
    }

    assert_response :unprocessable_entity
    assert_equal "employee@example.com", @user.reload.email
  end

  test "changes the email when the current password is valid" do
    patch user_registration_url, params: {
      user: {
        email: "nuevo_email@example.com",
        current_password: "password123"
      }
    }

    assert_redirected_to new_user_session_url
    assert_equal I18n.t("devise.registrations.updated_but_not_signed_in"), flash[:notice]
    assert_equal "nuevo_email@example.com", @user.reload.email
  end

  test "shows a success flash when changing the password" do
    patch user_registration_url, params: {
      user: {
        password: "nueva_password123",
        password_confirmation: "nueva_password123",
        current_password: "password123"
      }
    }

    assert_redirected_to new_user_session_url
    assert_equal I18n.t("devise.registrations.updated_but_not_signed_in"), flash[:notice]
    assert @user.reload.valid_password?("nueva_password123")
  end
end
