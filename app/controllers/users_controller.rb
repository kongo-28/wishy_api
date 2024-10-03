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
    render json: { action_plan: generate_action_plan }
  end

  # GET /users/candidate
  def candidate
    render json: { candidate: generate_candidate }
  end


  private

  def set_user
    @user = current_user
  end

  def set_test_user
    @user = User.find(2)
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

  def generate_action_plan
    chat_gpt_service = ChatGptService.new
    prompt = "500字以内で返して。話し言葉で返してください。以下のリストを参考にして次の日曜日のアクションプランを考えてください。wishは今後やってみたいことです。likesは熱意を表します。大きな数字ほどより強い気持ちです。「like」「wish」などの単語は適切に言い換えてください。"
    full_prompt = "#{prompt}\n\nWishリスト:\n#{@wish_descriptions}"
    chat_gpt_service.chat(full_prompt)
  end

  def generate_candidate
    chat_gpt_service = ChatGptService.new
    prompt = "500字以内で返して。話し言葉で返してください。以下のリストを参考にして私の好みを推測してください。その後、リストにあるもの以外で新たなwishを5個提案してください。新たな提案は、【】で囲ってください。wishは今後やってみたいことです。likesは熱意を表します。大きな数字ほどより強い気持ちです。「like」「wish」などの単語は適切に言い換えてください。"
    full_prompt = "#{prompt}\n\nWishリスト:\n#{@wish_descriptions}"
    chat_gpt_service.chat(full_prompt)
  end

end
