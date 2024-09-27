class LikesController < ApplicationController
  def create
    like = Like.find_or_initialize_by(user_id: params[:user_id], wish_id: params[:wish_id])
    like.count = params[:count]
    if like.save
      render json: { success: true, like: like }
    else
      render json: { success: false, errors: like.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
