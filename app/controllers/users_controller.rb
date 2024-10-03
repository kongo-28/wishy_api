class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[ index action candidate ]
  before_action :set_user, only: %i[ index action candidate ]
  # before_action :set_test_user, only: %i[ index action candidate ]
  before_action :set_wishes, only: %i[ index action candidate ]
  before_action :wishes_to_descriptions, only: %i[ action candidate ]

  # GET /users/:id
  def index
    render json: {user: @user,wishes: @wishes}
  end

  # GET /users/action
  def action
    chat_gpt_service = ChatGptService.new
    prompt= "500字以内で返して。話し言葉で返してください。以下のリストを参考にして次の日曜日のアクションプランを考えてください。wishは今後やってみたいことです。likesは熱意を表します。大きな数字ほどより強い気持ちです。「like」「wish」などの単語は適切に言い換えてください。"
    full_prompt = "#{prompt}\n\nWishリスト:\n#{@wish_descriptions}"
    @action_plan = chat_gpt_service.chat(full_prompt)

    render json: {action_plan:@action_plan}
  end

# GET /users/candidate
  def candidate
    chat_gpt_service = ChatGptService.new
    prompt= "500字以内で返して。話し言葉で返してください。以下のリストを参考にして私の好みを推測してください。その後、リストにあるもの以外で新たなwishを3つ提案してください。新たな提案は、【】で囲ってください。wishは今後やってみたいことです。likesは熱意を表します。大きな数字ほどより強い気持ちです。「like」「wish」などの単語は適切に言い換えてください。"
    full_prompt = "#{prompt}\n\nWishリスト:\n#{@wish_descriptions}"
    @candidate = chat_gpt_service.chat(full_prompt)

    render json: {candidate:@candidate}
    # render json: {full_prompt:full_prompt,candidate:@candidate}
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

  def wishes_to_descriptions
    @wish_descriptions = @wishes.map { 
      |wish| "Wish: #{wish["title"]}, likes: #{wish[:likes][0].count}" 
    }.join("\n")
  end

  def set_user
    @user = current_user
  end

  def set_test_user
    @user = User.find(2)
  end

end
