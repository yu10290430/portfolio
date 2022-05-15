class FavoritesController < ApplicationController

  def create
    @board = Board.find(params[:board_id])
    @favorite = current_user.favorites.new(board_id: @board.id)
    @favorite.save
    redirect_to board_path(@board)
  end

  def destroy
    @board = Board.find(params[:board_id])
    @favorite = current_user.favorites.find_by(board_id: @board.id)
    @favorite.destroy
    redirect_to board_path(@board)
  end
end
