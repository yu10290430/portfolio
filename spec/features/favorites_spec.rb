require 'rails_helper'

RSpec.feature "Favorites", type: :feature do
  given(:avatar) { file_upload("spec/fixtures/files/Certificate-CSS基礎.png","image/png") }
  given(:user) { create(:user, avatar: avatar) }
  given(:user2) { create(:user, avatar: avatar) }
  given(:board) { create(:board, user: user) }
  given!(:favorite) { create(:favorite, board: board, user: user) }

  describe "#create" do
    scenario "データベースに登録されること" do
      expect{ user2.favorites.new(board_id: board.id).save }.to change(Favorite, :count).by(1)
    end
  end


  describe "#destroy" do
    scenario "データベースから削除できること" do
      expect{ favorite.destroy }.to change(Favorite, :count).by(-1)
    end
  end
end
