class ChatsController < ApplicationController
  before_action :authenticate_user!, only: %i[ index create candidate ]
  before_action :set_user, only: %i[ index create candidate ]
  # before_action :set_test_user, only: %i[ index create candidate ]
  before_action :set_wishes, only: %i[ create candidate ]
  before_action :wishes_to_descriptions, only: %i[ create candidate ]

  # GET /chats
  def index
    @chats = Chat.where(user_id:@user.id)

    render json: {user: @user,chats:@chats}
  end

  # POST /chats
  def create
    @request = action_plan_params
    request_params = action_plan_params.merge(
                      title:"アクションプラン",
                      content:generate_action_plan_with_request,
                      user_id:current_user.id
                      )
    @chat = Chat.new( request_params)

    if @chat.save
      render json: @chat, status: :created, location: @user
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  # POST /chats/candidate
  def candidate
    @request = action_plan_params
    request_params = action_plan_params.merge(
                      title:"WISH候補",
                      content:generate_candidate_with_request,
                      user_id:current_user.id
                      )
    @chat = Chat.new( request_params)

    if @chat.save
      render json: @chat, status: :created, location: @user
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
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
      params.require(:chat).permit(:request)
    end

    def generate_action_plan_with_request
      chat_gpt_service = ChatGptService.new
      prompt = "500字以内で返して。話し言葉で返してください。追加の要望にある条件はできるだけ守ってください。以下のリストを参考にしてアクションプランを考えてください。wishは今後やってみたいことです。likesは熱意を表します。大きな数字ほどより強い気持ちです。「like」「wish」などの単語は適切に言い換えてください。"
      full_prompt = "#{prompt}\n\n追加の要望:\n#{@request}\n\nWishリスト:\n#{@wish_descriptions}"
      chat_gpt_service.chat(full_prompt)
    end

    def generate_candidate_with_request
      chat_gpt_service = ChatGptService.new
      prompt = "500字以内で返して。話し言葉で返してください。以下のリストを参考にして私の好みを推測してください。その後、リストにあるもの以外で新たなwishを5個提案してください。新たな提案は、【】で囲ってください。wishは今後やってみたいことです。likesは熱意を表します。大きな数字ほどより強い気持ちです。「like」「wish」などの単語は適切に言い換えてください。"
      full_prompt = "#{prompt}\n\n追加の要望:\n#{@request}\n\nWishリスト:\n#{@wish_descriptions}"
      chat_gpt_service.chat(full_prompt)
    end

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
