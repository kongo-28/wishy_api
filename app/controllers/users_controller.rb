class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[ index action action_plan candidate ]
  before_action :set_user, only: %i[ index action action_plan candidate ]
  # before_action :set_test_user, only: %i[ index action action_plan candidate ]
  before_action :set_wishes, only: %i[ index action action_plan candidate ]
  before_action :wishes_to_descriptions, only: %i[ action  action_plan candidate ]

  # GET /users/:id
  def index
    render json: {user: @user,wishes: @wishes}
  end

  private

  def set_user
    @user = current_user
  end

  def set_test_user
    @user = User.find(2)
  end

  # Only allow a list of trusted parameters through.
  def action_plan_params
    params.require(:user).permit(:request)
  end

  # ログインしているユーザーが1以上いいねしたwishとそれにひもづくlikeの情報のリスト
  def set_wishes
    @wishes = Wish.joins(:likes)
                  .where(likes: { user_id: @user.id })
                  .where('likes.count >= ?', 1)
                  .order(updated_at: :desc)
                  .map do |wish|
                    wish.as_json.merge(
                      likes: wish.likes.select { |like| like.user_id == @user.id }
                    )
                  end
  end

  def wishes_to_descriptions
    @wish_descriptions = @wishes.map { 
      |wish| "Wish: #{wish["title"]}, likes: #{wish[:likes][0].count}" 
    }.join("\n")
  end

end
