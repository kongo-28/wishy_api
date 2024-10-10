class WishesController < ApplicationController
  before_action :set_wish, only: %i[ show update destroy ]
  before_action :authenticate_user!, only: %i[ updata destoroy]

  # GET /wishes
  def index
    likes_sum = 0
    @user = current_user
    # @user = User.find(2)

    @wishes = Wish.includes(:likes).order("updated_at DESC")
    if @user.present?
      wishes_with_user_likes = @wishes.map do |wish|
        wish.as_json.merge(
        likes_user_count: wish.likes.count,
        likes: wish.likes.select { |like| like.user_id == @user.id }
        )
      end
      @wishes = wishes_with_user_likes
    end

    if @user.present?
      @wishes_user = Wish.joins(:likes)
      .where(likes: { user_id: @user.id })
      .where('likes.count >= ?', 1)
      .order(updated_at: :desc)
      .map do |wish|
        likes_sum += wish.likes[0].count
        wish.as_json.merge(
          likes_user_count: wish.likes.count,
          likes: wish.likes.select { |like| like.user_id == @user.id }
        )
      end
      @user = @user.as_json.merge(wish_count: @user.likes.count, likes_sum: likes_sum)
    end
      


    render json: {user: @user,wishes: @wishes, wishes_user: @wishes_user}
  end

  # GET /wishes/1
  def show
    render json: @wish
  end

  # POST /wishes
  def create
    @wish = Wish.new(wish_params)

    if @wish.save
      render json: @wish, status: :created, location: @wish
    else
      render json: @wish.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /wishes/1
  def update
    if @wish.update(wish_params)
      render json: @wish
    else
      render json: @wish.errors, status: :unprocessable_entity
    end
  end

  # DELETE /wishes/1
  def destroy
    @wish.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wish
      @wish = Wish.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def wish_params
      params.require(:wish).permit(:title, :content)
    end
end
