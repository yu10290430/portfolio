class BoardsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :search, :explanation]
  MAX_BOARD_COUNT = 6

  def index
    @boards = Board.includes(:user).order(created_at: :desc).limit(MAX_BOARD_COUNT)
    @board = Board.new(latitude: 35.681236, longitude: 139.767125)
    @ranks = Board.create_ranks
    @user_ranks = User.create_user_ranks
  end

  def create
    @board = Board.new(board_params)
    @board.user = current_user
    @boards = Board.includes(:user).order(created_at: :desc).limit(MAX_BOARD_COUNT)
    @ranks = Board.create_ranks
    @user_ranks = User.create_user_ranks
    if @board.save
      redirect_to search_boards_path, notice: "投稿できました"
    else
      flash.now[:alert] = "投稿できませんでした。入力内容をご確認ください"
      render "index"
    end
  end

  def show
    @board = Board.find(params[:id])
  end

  def edit
    @board = Board.find(params[:id])
  end

  def update
    @board = Board.find(params[:id])
    if @board.update(board_params)
      redirect_to board_path(@board), notice: "投稿内容を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました。入力内容を再度ご確認ください。"
      render "edit"
    end
  end

  def destroy
    @board = Board.find(params[:id])
    @board.destroy
    redirect_to root_path, notice: "投稿を削除しました"
  end

  def search
    @boards = Board.search(params[:keyword]).page(params[:page]).per(10)
  end

  private

  def board_params
    { user_id: current_user.id, latitude: 35.681236, longitude: 139.767125 }.
      merge(params.require(:board).
        permit(:title, :address, :weather, :kind, :date, :tide, :result, :body, :latitude, :longitude, images: []))
  end
end
