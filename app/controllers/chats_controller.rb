class ChatsController < ApplicationController

  # GET /chats
  def index
    @user = current_user
    # @user = User.find(2)
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
end
