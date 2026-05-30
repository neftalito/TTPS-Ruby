require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:employee)
    sign_in @user
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

    assert_response :redirect
    assert_equal "nuevo_email@example.com", @user.reload.email
  end
end
