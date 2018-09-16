require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template "users/show"
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'h3', text: "Microposts (#{@user.microposts.count})"
    assert_select 'div.pagination'
    assert_select 'div.pagination', count: 1
    # debugger

    assert_select 'strong#following', text: @user.following.count.to_s
    assert_equal 2, @user.following.count
    assert_match @user.following.count.to_s, response.body
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end

  end

end
