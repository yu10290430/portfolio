require 'rails_helper'

RSpec.feature "Relationship", type: :feature do
  given(:avatar) { file_upload("spec/fixtures/files/Certificate-CSS基礎.png","image/png") }
  given(:user) { create(:user, avatar: avatar) }
  given(:user2) { create(:user, avatar: avatar) }
  given(:user3) { create(:user, avatar: avatar) }
  given!(:relationship) { create(:relationship, user: user, follow: user2) }

  describe "#create" do
    scenario "データベースに登録されること" do
      expect{ user.follow(user3).save }.to change(Relationship, :count).by(1)
    end
  end


  describe "#destroy" do
    scenario "データベースから削除できること" do
      expect{ relationship.destroy }.to change(Relationship, :count).by(-1)
    end
  end
end
