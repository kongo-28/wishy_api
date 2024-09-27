class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[ show ]

  # GET /users/:id
  def show
    @user = current_user
    # @user = User.find(2)
    @wishes = Wish.includes(:likes).all

    if @user.present?
      wishes_with_user_likes = @wishes.map do |wish|
        wish.as_json.merge(
        likes: wish.likes.select { |like| like.user_id == @user.id }
        )
      end
      @wishes = wishes_with_user_likes
    end

    render json: {user: @user,wishes: @wishes}
  end

end
