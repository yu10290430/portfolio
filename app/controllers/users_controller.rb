class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "ユーザー情報を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました。入力内容を再度ご確認ください。"
      render "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to root_path, notice: "アカウントを削除しました"
  end

  def favorites
    @user = User.find(params[:id])
    favorites = Favorite.where(user_id: @user.id).pluck(:board_id)
    @favorite_boards = Board.find(favorites)
  end

  def user_posts
    @user = User.find(params[:id])
    posts = Board.where(user_id: @user.id).order(created_at: :desc).pluck(:id)
    @user_posts = Board.find(posts)
  end

  def followings
    @user = User.find(params[:id])
    @following_users = @user.followings
  end

  def followers
    @user = User.find(params[:id])
    @follower_users = @user.followers
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :avatar, :introduction)
  end
end
