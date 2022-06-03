require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let!(:avatar) { file_upload("spec/fixtures/files/Certificate-CSS基礎.png","image/png") }
  let!(:user) { create(:user, avatar: avatar) }
  let!(:other_user) { create(:user, avatar: avatar) }
  let!(:follow) {create(:relationship, user: user, follow: other_user)}

  describe "フォロー機能" do
    it "user_id、follow_idがある場合、有効である" do
      expect(follow).to be_valid
    end

    it "user_id、follow_idが空の場合登録できない" do
      expect(build(:relationship, user_id: "")).to_not be_valid
      expect(build(:relationship, follow_id: "") ).to_not be_valid
    end
  end
end
