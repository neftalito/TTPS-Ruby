require "test_helper"

class Backstore::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:admin)
  end

  test "shows the users index" do
    get backstore_users_url

    assert_response :success
  end

  test "shows the edit page for an existing user" do
    get edit_backstore_user_url(users(:employee))

    assert_response :success
  end

  test "creates a user" do
    assert_difference("User.count", 1) do
      post backstore_users_url, params: {
        user: {
          email: "nuevo_usuario@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "employee"
        }
      }
    end

    created_user = User.find_by!(email: "nuevo_usuario@example.com")

    assert_redirected_to backstore_users_url
    assert created_user.employee?
    assert_equal I18n.default_locale.to_s, created_user.locale
  end

  test "updates a user without changing the password when it is blank" do
    user = users(:employee)

    patch backstore_user_url(user), params: {
      user: {
        email: "empleado_actualizado@example.com",
        password: "",
        password_confirmation: "",
        role: "manager"
      }
    }

    assert_redirected_to backstore_users_url
    assert_equal "empleado_actualizado@example.com", user.reload.email
    assert user.manager?
  end

  test "soft deletes a user" do
    user = users(:manager)

    delete backstore_user_url(user)

    assert_redirected_to backstore_users_url
    assert User.find(user.id).deleted?
  end

  test "restores a deleted user" do
    user = users(:deleted_employee)

    patch restore_backstore_user_url(user)

    assert_redirected_to backstore_users_url
    assert_not User.find(user.id).deleted?
  end

  test "creates a user" do
    assert_difference("User.count", 1) do
      post backstore_users_url, params: {
        user: {
          email: "nuevo_usuario@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "employee"
        }
      }
    end

    created_user = User.find_by!(email: "nuevo_usuario@example.com")

    assert_redirected_to backstore_users_url
    assert created_user.employee?
    assert_equal I18n.default_locale.to_s, created_user.locale
  end

  test "updates a user without changing the password when it is blank" do
    user = users(:employee)

    patch backstore_user_url(user), params: {
      user: {
        email: "empleado_actualizado@example.com",
        password: "",
        password_confirmation: "",
        role: "manager"
      }
    }

    assert_redirected_to backstore_users_url
    assert_equal "empleado_actualizado@example.com", user.reload.email
    assert user.manager?
  end

  test "soft deletes a user" do
    user = users(:manager)

    delete backstore_user_url(user)

    assert_redirected_to backstore_users_url
    assert User.find(user.id).deleted?
  end

  test "restores a deleted user" do
    user = users(:deleted_employee)

    patch restore_backstore_user_url(user)

    assert_redirected_to backstore_users_url
    assert_not User.find(user.id).deleted?
  end

  test "manager can restore deleted employees" do
    sign_out :user
    sign_in users(:manager)
    user = users(:deleted_employee)

    patch restore_backstore_user_url(user)

    assert_redirected_to backstore_users_url
    assert_not user.reload.deleted?
  end

  test "prevents deleting the current user" do
    user = users(:admin)

    delete backstore_user_url(user)

    assert_redirected_to backstore_users_url
    assert_not user.reload.deleted?
  end

  test "prevents changing the current user role" do
    user = users(:admin)

    patch backstore_user_url(user), params: {
      user: {
        email: user.email,
        role: "manager"
      }
    }

    assert_redirected_to backstore_users_url
    assert user.reload.admin?
  end

  test "manager cannot create admin users" do
    sign_out :user
    sign_in users(:manager)

    assert_no_difference("User.count") do
      post backstore_users_url, params: {
        user: {
          email: "otro_admin@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "admin"
        }
      }
    end

    assert_response :redirect
    assert_nil User.find_by(email: "otro_admin@example.com")
  end

  test "manager cannot update admin users" do
    sign_out :user
    sign_in users(:manager)
    admin = users(:admin)

    patch backstore_user_url(admin), params: {
      user: {
        email: "admin_actualizado@example.com",
        role: "admin"
      }
    }

    assert_redirected_to backstore_root_url
    assert_equal "admin@example.com", admin.reload.email
  end

  test "employees cannot access user management" do
    sign_out :user
    sign_in users(:employee)

    get backstore_users_url

    assert_redirected_to backstore_root_url
  end

  test "managers cannot restore deleted managers" do
    user = User.create!(
      email: "deleted_manager_#{Time.current.to_f.to_s.delete('.')}@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "manager"
    )
    user.destroy

    sign_out :user
    sign_in users(:manager)

    patch restore_backstore_user_url(user)

    assert_response :redirect
    assert user.reload.deleted?
  end

  test "creates a user" do
    assert_difference("User.count", 1) do
      post backstore_users_url, params: {
        user: {
          email: "nuevo_usuario@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "employee"
        }
      }
    end

    created_user = User.find_by!(email: "nuevo_usuario@example.com")

    assert_redirected_to backstore_users_url
    assert created_user.employee?
    assert_equal I18n.default_locale.to_s, created_user.locale
  end

  test "updates a user without changing the password when it is blank" do
    user = users(:employee)

    patch backstore_user_url(user), params: {
      user: {
        email: "empleado_actualizado@example.com",
        password: "",
        password_confirmation: "",
        role: "manager"
      }
    }

    assert_redirected_to backstore_users_url
    assert_equal "empleado_actualizado@example.com", user.reload.email
    assert user.manager?
  end

  test "soft deletes a user" do
    user = users(:manager)

    delete backstore_user_url(user)

    assert_redirected_to backstore_users_url
    assert User.find(user.id).deleted?
  end

  test "restores a deleted user" do
    user = users(:deleted_employee)

    patch restore_backstore_user_url(user)

    assert_redirected_to backstore_users_url
    assert_not User.find(user.id).deleted?
  end

  test "manager can restore deleted employees" do
    sign_out :user
    sign_in users(:manager)
    user = users(:deleted_employee)

    patch restore_backstore_user_url(user)

    assert_redirected_to backstore_users_url
    assert_not user.reload.deleted?
  end

  test "prevents deleting the current user" do
    user = users(:admin)

    delete backstore_user_url(user)

    assert_redirected_to backstore_users_url
    assert_not user.reload.deleted?
  end

  test "prevents changing the current user role" do
    user = users(:admin)

    patch backstore_user_url(user), params: {
      user: {
        email: user.email,
        role: "manager"
      }
    }

    assert_redirected_to backstore_users_url
    assert user.reload.admin?
  end

  test "manager cannot create admin users" do
    sign_out :user
    sign_in users(:manager)

    assert_no_difference("User.count") do
      post backstore_users_url, params: {
        user: {
          email: "otro_admin@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "admin"
        }
      }
    end

    assert_response :redirect
    assert_nil User.find_by(email: "otro_admin@example.com")
  end

  test "manager cannot update admin users" do
    sign_out :user
    sign_in users(:manager)
    admin = users(:admin)

    patch backstore_user_url(admin), params: {
      user: {
        email: "admin_actualizado@example.com",
        role: "admin"
      }
    }

    assert_redirected_to backstore_root_url
    assert_equal "admin@example.com", admin.reload.email
  end

  test "employees cannot access user management" do
    sign_out :user
    sign_in users(:employee)

    get backstore_users_url

    assert_redirected_to backstore_root_url
  end

  test "managers cannot restore deleted managers" do
    user = User.create!(
      email: "deleted_manager_#{Time.current.to_f.to_s.delete('.')}@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: "manager"
    )
    user.destroy

    sign_out :user
    sign_in users(:manager)

    patch restore_backstore_user_url(user)

    assert_response :redirect
    assert user.reload.deleted?
  end
end
