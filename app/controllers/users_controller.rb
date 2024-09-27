class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[ index ]

  # GET /users/:id
  def index
    # @user = current_user
    @user = User.find(2)
    @wishes = Wish.joins(:likes)
    .where(likes: { user_id: @user.id })
    .where('likes.count >= ?', 1)
    .order("updated_at DESC")
######################################################
###########ユーザーが1以上いいねをしているwishのみ取得する
######################################################
    # if @user.present?
      wishes_with_user_likes = @wishes.map do |wish|
        wish.as_json.merge(
        likes: wish.likes.select { |like| like.user_id == @user.id }
        )
      end
      @wishes = wishes_with_user_likes
    # end

    render json: {user: @user,wishes: @wishes}
  end

end
