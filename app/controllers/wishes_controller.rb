class WishesController < ApplicationController
  before_action :set_wish, only: %i[ show update destroy ]
  before_action :authenticate_user!, only: %i[ updata destoroy]

  # GET /wishes
  def index
    @wishes = Wish.all.order("updated_at DESC")
    @user = current_user

    render json: {wishes:@wishes, user:@user}
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
