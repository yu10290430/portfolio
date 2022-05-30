require 'rails_helper'

RSpec.describe Favorite, type: :model do
  let!(:avatar) { file_upload("spec/fixtures/files/Certificate-CSS基礎.png","image/png") }
  let!(:user) { create(:user, avatar: avatar) }
  let!(:board) { create(:board, user: user ) }
  let!(:favorited_board) {create(:favorite, user: user, board: board)}

  describe "お気に入り登録" do
    it "user_id、board_idがある場合、有効である" do
      expect(favorited_board).to be_valid
    end

    it "board_id、user_idが空の場合登録できない" do
      expect(build(:favorite, board_id: "")).to_not be_valid
      expect(build(:favorite, user_id: "")).to_not be_valid
    end
  end
end
