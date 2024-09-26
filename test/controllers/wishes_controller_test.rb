require "test_helper"

class WishesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @wish = wishes(:one)
  end

  test "should get index" do
    get wishes_url, as: :json
    assert_response :success
  end

  test "should create wish" do
    assert_difference("Wish.count") do
      post wishes_url, params: { wish: { content: @wish.content, name: @wish.name } }, as: :json
    end

    assert_response :created
  end

  test "should show wish" do
    get wish_url(@wish), as: :json
    assert_response :success
  end

  test "should update wish" do
    patch wish_url(@wish), params: { wish: { content: @wish.content, name: @wish.name } }, as: :json
    assert_response :success
  end

  test "should destroy wish" do
    assert_difference("Wish.count", -1) do
      delete wish_url(@wish), as: :json
    end

    assert_response :no_content
  end
end
