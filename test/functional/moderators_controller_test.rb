require File.dirname(__FILE__) + '/../test_helper'
require 'moderators_controller'

# Re-raise errors caught by the controller.
class ModeratorsController; def rescue_action(e) raise e end; end

class ModeratorsControllerTest < Test::Unit::TestCase
  all_fixtures
  def setup
    @controller = ModeratorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_delete_moderatorship
    assert users(:sam).moderator_of?(categories(:rails))
    login_as :aaron
    assert_difference Moderatorship, :count, -1 do
      delete :destroy, :user_id => users(:sam).id, :id => moderatorships(:sam_rails).id
    end
    assert_redirected_to user_path(users(:sam))
    assert !users(:sam).moderator_of?(categories(:rails))
  end

  def test_should_only_allow_admins_to_delete_moderatorships
    login_as :sam
    assert_difference Moderatorship, :count, 0 do
      delete :destroy, :user_id => users(:sam).id, :id => moderatorships(:sam_rails).id
    end
    assert_redirected_to login_path
  end
end
