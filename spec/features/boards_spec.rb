require 'rails_helper'

RSpec.feature "Boards", type: :feature do
  given(:avatar) { file_upload("spec/fixtures/files/Certificate-CSS基礎.png","image/png") }
  given(:user) { create(:user, avatar: avatar) }
  given(:other_users) { create_list(:user, 3, avatar: avatar) }
  given!(:board) { create(:board, user: user) }
  given!(:board2) { create(:board, user: other_users[0]) }
  given!(:board3) { create(:board, user: other_users[1]) }
  given!(:board4) { create(:board, user: other_users[2]) }
  given!(:new_boards) { create_list(:board, 7, user: user, created_at: "2022-05-01") }
  given(:new_board1) { new_boards[0] }
  given!(:favorite) { create(:favorite, board: board2, user: user) }
  given!(:favorites1) { create_list(:favorite, 2, board: board3, user: user)}
  given!(:favorites2) { create_list(:favorite, 3, board: board4, user: user)}
  given!(:follower) { create(:relationship, user: other_users[0], follow: user)}
  given!(:rank2_follower1) { create(:relationship, user: user, follow: other_users[0])}
  given!(:rank2_follower2) { create(:relationship, user: other_users[1], follow: other_users[0])}
  given!(:rank1_follower1) { create(:relationship, user: user, follow: other_users[1])}
  given!(:rank1_follower2) { create(:relationship, user: other_users[0], follow: other_users[1])}
  given!(:rank1_follower3) { create(:relationship, user: other_users[2], follow: other_users[1])}

  background do
    visit new_user_session_path
    fill_in("user_email", with: user.email)
    fill_in("user_password", with: user.password)
    click_button "ログイン"
  end

  describe "#index" do
    background do
      visit root_path
      new_board1.user = other_users[0]
    end

    scenario "レスポンスのステータスが正しいこと" do
      expect(page).to have_http_status(200)
    end

    scenario "投稿一覧へのリンクが正常に機能していること" do
      click_on "投稿一覧はこちら"
      expect(current_path).to eq boards_search_path
    end

    scenario "新規投稿機能が正常に機能していること" do
      fill_in("board_title", with: "title")
      fill_in("board_address", with: "佐賀県")
      select "晴れ", from: "天気"
      fill_in("board_kind", with: "うき釣り")
      fill_in("board_date", with: "2022-05-16")
      select '大潮', from: "潮"
      fill_in("board_result", with: 3)
      fill_in("board_body", with: "いいね")
      expect{
        find('input[name="commit"]').click
      }.to change { Board.count }.by(1)
      expect(current_path).to eq boards_search_path
      expect(page).to have_content "投稿できました"
    end

    scenario "新規投稿に不備がある場合の振る舞い" do
      fill_in("board_title", with: "")
      expect{
        find('input[name="commit"]').click
      }.to change { Board.count }.by(0)
      expect(current_path).to eq root_path
      expect(page).to have_content "投稿できませんでした。入力内容をご確認ください"
    end

    scenario "作成日の新しい投稿が6件表示されていること" do
      within ".new_arrival" do
        new_boards[0..5].all? do |new_board|
          expect(page).to have_content new_board.title
        end
        expect(page).to have_no_content new_boards[6].title
        expect(page).to have_no_content board.title
      end
    end

    scenario "新着情報の投稿詳細ページへのリンクが正常に機能していること" do
      within ".new_arrival" do
        click_on new_board1.title
        expect(current_path).to eq board_path(new_board1.id)
      end
    end

    scenario "新着情報のユーザー詳細ページへのリンクが正常に機能していること" do
      click_link new_board1.user.name
      expect(current_path).to eq user_path(other_users[0].id)
    end

    scenario "ランキング内にいいね数の多い順に投稿が３件表示されること" do
      within ".rank_body" do
        expect(page).to have_content "第1位\n#{board4.title}\n第2位\n#{board3.title}\n第3位\n#{board2.title}"
        expect(page).to have_no_content board.title
      end
    end

    scenario "ランキング内にフォロワー数の多い順にユーザー名が３件表示されること" do
      within ".rank_body" do
        expect(page).to have_content "第1位\n#{other_users[1].name}\n第2位\n#{other_users[0].name}\n第3位\n#{user.name}"
        expect(page).to have_no_content other_users[2].name
      end
    end
  end

  describe "#show" do
    context "いいねしていない投稿" do
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

      scenario "いいねボタンが表示されていること" do
        expect(page).to have_content "♡"
      end

      scenario "いいね削除ボタンをクリックした際の振る舞い" do
        expect{
          click_on "♡"
        }.to change { Favorite.count }.by(1)
        expect(page).to have_content "♥"
        expect(page).to have_no_content "♡"
      end
    end

    context "いいね済みの投稿" do
      background do
        visit board_path(board2.id)
      end

      scenario "いいね削除ボタンが表示されていること" do
        expect(page).to have_content "♥"
      end

      scenario "いいね削除ボタンをクリックした際の振る舞い" do
        expect{
          click_on "♥"
        }.to change { Favorite.count }.by(-1)
        expect(page).to have_content "♡"
        expect(page).to have_no_content "♥"
      end

      scenario "ページに表示されているいいね件数と投稿に紐づくいいねの件数が等しいこと" do
        expect(page).to have_selector(".favorites", count: board2.favorites.count)
      end
    end
  end

  describe "#edit" do
    background do
      visit edit_board_path(board.id)
    end

    scenario "レスポンスのステータスが正しいこと" do
      expect(page).to have_http_status(200)
    end

    scenario "正常にアップデートが機能していること" do
      fill_in("board_title", with: "update")
      click_on "更新する"
      expect(current_path).to eq board_path(board.id)
      expect(page).to have_content "投稿内容を更新しました"
      expect(board.reload.title).to eq "update"
    end

    scenario "アップデートに失敗したときの振る舞い" do
      fill_in("board_title", with: "")
      click_on "更新する"
      expect(page).to have_content "更新に失敗しました。入力内容に不備がないかご確認ください。"
    end

    scenario "投稿詳細ページへのリンクが正常に機能していること" do
      click_on "投稿詳細に戻る"
      expect(current_path).to eq board_path(board.id)
    end

    scenario "削除ボタンが正常に機能していること" do
      expect{
        click_on "投稿削除"
      }.to change { Board.count }.by(-1)
      expect(current_path).to eq root_path
      expect(page).to have_content "投稿を削除しました"
    end
  end

  describe "#destroy" do
    scenario "投稿を削除できること" do
      expect{ board.destroy }.to change(Board, :count).by(-1)
    end
  end

  describe "#search" do
    background do
      visit boards_search_path
    end

    scenario "レスポンスのステータスが正しいこと" do
      expect(page).to have_http_status(200)
    end

    scenario "検索機能が正常に機能していること" do
      fill_in("keyword", with: board.title)
      click_on "検索"
      expect(page).to have_content board.title
      expect(page).to have_no_content board2.title
    end

    scenario "検索キーワードが空の時の振る舞い" do
      fill_in("keyword", with: "")
      click_on "検索"
      expect(page).to have_content board.title
      expect(page).to have_content board2.title
      expect(page).to have_content board3.title
      expect(page).to have_content board4.title
    end

    scenario "投稿タイトルのリンクが正常に機能していること" do
      click_on board.title
      expect(current_path).to eq board_path(board.id)
    end

    scenario "ユーザー名のリンクが正常に機能していること" do
      click_on board2.user.name
      expect(current_path).to eq user_path(other_users[0].id)
    end
  end
end
