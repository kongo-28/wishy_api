class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[ index action ]
  before_action :set_user, only: %i[ index action ]
  before_action :set_wishes, only: %i[ index action ]

  # GET /users/:id
  def index
    render json: {user: @user,wishes: @wishes}
  end

  # GET /users/action
  def action

    wish_descriptions = @wishes.map { 
      |wish| "Wish: #{wish["title"]}, likes: #{wish[:likes][0].count}" 
    }.join("\n")

    chat_gpt_service = ChatGptService.new
    prompt= "wishは今後やってみたいことです。likesはやりたい気持ちを表していて、大きな数字ほどより強い気持ちです。これを参考にして次の日曜日のアクションプランを考えてください。"
    full_prompt = "#{prompt}\n\nWishリスト:\n#{wish_descriptions}"
    @action_plan = chat_gpt_service.chat(full_prompt)

    render json: full_prompt
  end

  private

  # ログインしているユーザーが1以上いいねしたwishとそれにひもづくlikeの情報のリスト
  def set_wishes
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
  end

  def set_user
    @user = current_user
  end


end
