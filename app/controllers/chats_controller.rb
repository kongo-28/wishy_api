class ChatsController < ApplicationController

  # GET /chats
  def index
    # @user = current_user
    @user = User.find(2)
    @chats = Chat.where(user_id:@user.id)

    render json: {user: @user,chats:@chats}
  end
end
