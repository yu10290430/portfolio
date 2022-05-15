require 'rails_helper'

RSpec.feature "Boards", type: :feature do
  #binding.pry
  let!(:user) { create(:user) }
  let!(:board) { create(:board, users: [user]) }

  describe "#show" do
    background do
      visit board_path(board.id)
    end

    scenario "レスポンスのステータスが正しいこと" do
      expect(page).to have_http_status(200)
    end

    scenario "詳細ページに正しい値が表示されていること" do
      expect(page).to have_content board.title
      expect(page).to have_content board.weather
      expect(page).to have_content board.kind
      expect(page).to have_content board.date
      expect(page).to have_content board.tide
      expect(page).to have_content board.result
      expect(page).to have_content board.address
      expect(page).to have_content board.body
    end

    scenario "メインページへのリンクが正常に機能していること" do
      click_on "投稿一覧に戻る"
      expect(current_path).to eq boards_search_path
    end

    scenario "編集ページへのリンクが正常に機能していること" do
      click_on "編集する"
      expect(current_path).to eq edit_board_path(board.id)
    end
  end
end
