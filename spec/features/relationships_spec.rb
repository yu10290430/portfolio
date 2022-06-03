require 'rails_helper'

RSpec.feature "Relationship", type: :feature do
  given(:user) { create(:user) }
  given(:user2) { create(:user) }
  given(:user3) { create(:user) }
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
