require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:avatar) { file_upload("spec/fixtures/files/Certificate-CSS基礎.png","image/png") }
  let(:user) { create(:user, avatar: avatar) }
  let(:other_users) { create_list(:user, 3, avatar: avatar) }
  let!(:follower) { create(:relationship, user: other_users[0], follow: other_users[2])}
  let!(:rank2_follower1) { create(:relationship, user: other_users[1], follow: other_users[0])}
  let!(:rank2_follower2) { create(:relationship, user: other_users[2], follow: other_users[0])}
  let!(:rank1_follower1) { create(:relationship, user: user, follow: other_users[1])}
  let!(:rank1_follower2) { create(:relationship, user: other_users[0], follow: other_users[1])}
  let!(:rank1_follower3) { create(:relationship, user: other_users[2], follow: other_users[1])}

  describe "ユーザー新規登録" do
    it "名前、メール、パスワード、パスワード確認、プロフィール画像がある場合、有効である" do
      expect(user).to be_valid
    end

    it "名前が空の場合登録できない" do
      expect(build(:user, name: "")).to_not be_valid
    end

    it "メールアドレスが空の場合登録できない" do
      expect(build(:user, email: "")).to_not be_valid
    end

    it "メールアドレスが重複している場合、登録できない" do
      expect(build(:user, email: user.email)).to_not be_valid
    end

    it "パスワードが空の場合登録できない" do
      expect(build(:user, name: "")).to_not be_valid
    end

    it "画像が空の場合登録できない" do
      expect(build(:user)).to_not be_valid
    end

    it "password_confirmationとpasswordが異なる場合保存できない" do
      expect(build(:user, password: "password", password_confirmation: "passward")).to_not be_valid
    end
  end

  describe "フォロー機能について" do
    it "ユーザーが他のユーザーをフォロー可能であること" do
      user.follow(other_users[0])
      expect(user.following?(other_users[0])).to eq true
    end

    it "ユーザーが他のユーザーをフォロー解除可能であること" do
      user.unfollow(other_users[1])
      expect(user.following?(other_users[1])).to eq false
    end
  end

  describe "フォロワー数ランキングについて" do
    it "期待する値を3件取得できていること" do
      expect(User.create_user_ranks).to match_array other_users
      expect(User.create_user_ranks).not_to include user
    end

    it "並び順がフォロワー数の多い順になっていること" do
      expect(User.create_user_ranks[0]).to eq other_users[1]
    end
  end
end
