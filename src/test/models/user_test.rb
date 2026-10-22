require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "soft deleted users are inactive for authentication" do
    user = users(:deleted_employee)

    assert_not user.active_for_authentication?
    assert_equal :inactive, user.inactive_message
  end
end
