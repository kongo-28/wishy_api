class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[ index ]

  # GET /users/:id
  def index
    @user = current_user
    @wishes = Wish.joins(:likes)
    .where(likes: { user_id: @user.id })
    .where('likes.count >= ?', 1)
    .order("updated_at DESC")
      wishes_with_user_likes = @wishes.map do |wish|
        wish.as_json.merge(
        likes: wish.likes.select { |like| like.user_id == @user.id }
        )
      end
    @wishes = wishes_with_user_likes

    render json: {user: @user,wishes: @wishes}
  end

end
