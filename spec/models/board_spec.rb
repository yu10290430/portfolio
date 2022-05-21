require 'rails_helper'

RSpec.describe Board, type: :model do
  let!(:avatar) { file_upload("spec/fixtures/files/Certificate-CSS基礎.png","image/png") }
  let(:user) { create(:user, avatar: avatar) }
  let!(:other_user) { create(:user, avatar: avatar) }
  let!(:board) { create(:board, user: user) }
  let!(:boards) { create_list(:board, 3, user: user) }
  let!(:favorited_board) {create(:favorite, user: other_user, board: board)}
  let!(:favorited_boards1) {create_list(:favorite, 4, user: other_user, board: boards[0])}
  let!(:favorited_boards2) {create_list(:favorite, 3, user: other_user, board: boards[1])}
  let!(:favorited_boards3) {create_list(:favorite, 2, user: other_user, board: boards[2])}

  describe "新規投稿" do
    it "新規投稿の入力内容が有効である" do
      expect(board).to be_valid
    end

    it "タイトルが空の場合登録できない" do
      expect(build(:board, title: "")).to_not be_valid
    end

    it "タイトルが20字以下でない場合登録出来ないこと" do
      over_title = "a" * 21
      expect(build(:board, title: over_title)).to_not be_valid
    end

    it "天気が空の場合登録できない" do
      expect(build(:board, weather: "")).to_not be_valid
    end

    it "住所が空の場合登録できない" do
      expect(build(:board, address: "")).to_not be_valid
    end

    it "釣種が空の場合登録できない" do
      expect(build(:board, kind: "")).to_not be_valid
    end

    it "日付が空の場合登録できない" do
      expect(build(:board, date: "")).to_not be_valid
    end

    it "今日以前の日付出ない場合登録できない" do
      expect(build(:board, date: Date.tomorrow)).to_not be_valid
    end

    it "潮が空の場合登録できない" do
      expect(build(:board, tide: "")).to_not be_valid
    end

    it "釣果が空の場合登録できない" do
      expect(build(:board, result: "")).to_not be_valid
    end

    it "テキストが空の場合登録できない" do
      expect(build(:board, body: "")).to_not be_valid
    end

    it "テキストが200字以下でない場合登録出来ないこと" do
      over_text = "b" * 201
      expect(build(:board, body: over_text)).to_not be_valid
    end
  end

  describe "いいね機能について" do
    it "いいねしたユーザー情報がデータベースに存在すること" do
      expect(board.favorited_by?(other_user)).to be true
    end
  end

  describe "投稿いいね数ランキングについて" do
    it "期待する値を3件取得できていること" do
      expect(Board.create_ranks).to match_array boards
      expect(Board.create_ranks).not_to include board
    end

    it "並び順がいいね数の多い順になっていること" do
      expect(Board.create_ranks[0]).to eq boards[0]
    end
  end

  describe "検索機能について" do
    it "キーワードに基づくデータのみを取得できること" do
      expect(Board.search(board.title)).to include board
      expect(Board.search(board.title)).to_not include boards[0]
    end

    it "キーワードが空欄の場合データを全件取得すること" do
      expect(Board.search(nil)).to include board
      expect(Board.search(nil)).to include boards[0]
      expect(Board.search(nil)).to include boards[1]
      expect(Board.search(nil)).to include boards[2]
    end
  end
end
