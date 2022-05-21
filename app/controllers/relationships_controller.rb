class RelationshipsController < ApplicationController

  def create
    @user = User.find(params[:follow_id])
    following = current_user.follow(@user)
    if following.save
      flash[:notice] = "#{@user.name}をフォローしました"
      redirect_to @user
    else
      flash.now[:alert] = "#{@user.name}のフォローに失敗しました"
      redirect_to @user
    end
  end

  def destroy
    @user = User.find(params[:follow_id])
    following = current_user.unfollow(@user)
    if following.destroy
      flash[:notice] = "#{@user.name}のフォローを解除しました"
      redirect_to @user
    else
      flash.now[:alert] = "#{@user.name}のフォロー解除に失敗しました"
      redirect_to @user
    end
  end

end
