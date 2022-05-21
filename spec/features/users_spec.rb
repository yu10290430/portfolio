require 'rails_helper'

RSpec.feature "Users", type: :feature do
  given(:avatar) { file_upload("spec/fixtures/files/Certificate-CSS基礎.png","image/png") }
  given(:user) { create(:user, avatar: avatar) }
  given(:other_users) { create_list(:user, 3, avatar: avatar) }
  given!(:board) { create(:board, user: user) }
  given(:board2) { create(:board, user: other_users[0]) }
  given!(:favorite_board) { create(:favorite, user: user, board: board2) }
  given(:not_favorite_board) { create(:favorite, user: other_users[0], board: board) }
  given!(:follow) { create(:relationship, user: user, follow: other_users[1]) }
  given(:unfollow) { create(:relationship, user: other_users[0], follow: other_users[2]) }
  given!(:follower) { create(:relationship, user: other_users[0], follow: user) }
  given(:not_follower) { create(:relationship, user: other_users[1], follow: other_users[0]) }

  context "ログインしていない状態"do
    describe "新規登録ページ" do
      background do
        visit new_user_registration_path
      end

      scenario "新規登録機能が正常に機能していること" do
        fill_in("user_name", with: "tarou")
        fill_in("user_email", with: "test@example.com")
        fill_in("user_password", with: "password")
        fill_in("user_password_confirmation", with: "password")
        attach_file('user_avatar', "spec/fixtures/files/Certificate-CSS基礎.png")
        expect{
          find('input[name="commit"]').click
        }.to change { User.count }.by(1)
        expect(current_path).to eq root_path
        expect(page).to have_content "アカウント登録が完了しました"
      end

      scenario "新規登録時に不備がある場合の振る舞い" do
        fill_in("user_name", with: "")
        expect{
          find('input[name="commit"]').click
        }.to change { User.count }.by(0)
        expect(current_path).to eq new_user_registration_path
      end

      scenario "ログインページへのリンクが正常に機能していること" do
        within ".field_box" do
          click_on "ログイン"
        end
        expect(current_path).to eq new_user_session_path
      end
    end

    describe "ログインページ" do
      background do
        visit new_user_session_path
      end
      scenario "ログイン機能が正常に機能していること" do
        fill_in("user_email", with: user.email)
        fill_in("user_password", with: user.password)
        click_button "ログイン"
        expect(current_path).to eq root_path
        expect(page).to have_content "ログインしました。"
      end

      scenario "新規登録へのリンクが正常に機能していること" do
        within ".link_box" do
          click_on "新規登録"
        end
        expect(current_path).to eq new_user_registration_path
      end

      scenario "パスワードを忘れた場合のリンクが正常に機能していること" do
        click_on "パスワードを忘れた場合"
        expect(current_path).to eq new_user_password_path
      end
    end
  end

  context "ログイン中の状態" do
    background do
      visit new_user_session_path
      fill_in("user_email", with: user.email)
      fill_in("user_password", with: user.password)
      click_button "ログイン"
    end

    describe "#show" do
      context "ログイン中のユーザー詳細ページの場合" do
        background do
          visit user_path(user.id)
        end

        scenario "レスポンスのステータスが正しいこと" do
          expect(page).to have_http_status(200)
        end

        scenario "正しい値が取得できていること" do
          expect(page).to have_content user.name
          expect(page).to have_content user.email
          expect(page).to have_content user.introduction
        end

        scenario "投稿一覧ページへのリンクが正常に機能していること" do
          click_on "投稿"
          expect(current_path).to eq user_posts_user_path(user.id)
        end

        scenario "いいね一覧ページへのリンクが正常に機能していること" do
          click_on "いいね"
          expect(current_path).to eq favorites_user_path(user.id)
        end

        scenario "フォロー一覧ページへのリンクが正常に機能していること" do
          click_on "フォロー中"
          expect(current_path).to eq followings_user_path(user.id)
        end

        scenario "プロフィール編集ページへのリンクが正常に機能していること" do
          click_on "プロフィール編集"
          expect(current_path).to eq edit_user_path(user.id)
        end

        scenario "フォローボタンが表示されていないこと" do
          expect(page).to have_no_button "フォローする"
        end
      end

      context "他のユーザー詳細ページの場合" do
        background do
          visit user_path(other_users[0].id)
        end

        scenario "フォローボタンが表示されていること" do
          expect(page).to have_button "フォローする"
        end

        scenario "フォローボタンをクリックした際の振る舞い" do
          expect{
            click_on "フォローする"
          }.to change { Relationship.count }.by(1)
          expect(page).to have_content "#{other_users[0].name}をフォローしました"
          expect(page).to have_button "フォローを解除"
          expect(page).to have_no_button "フォローする"
        end

        scenario "メールアドレスが表示されていないこと" do
          expect(page).to have_no_content other_users[0].email
        end

        scenario "プロフィール編集ページへのリンクが表示されないこと" do
          expect(page).to have_no_link edit_user_path(other_users[0].id)
        end
      end

      context "フォローしている他のユーザー詳細ページの場合" do
        background do
          visit user_path(other_users[1].id)
        end

        scenario "フォロー解除ボタンが表示されていること" do
          expect(page).to have_button "フォローを解除"
        end

        scenario "フォロー解除ボタンをクリックした際の振る舞い" do
          expect{
            click_on "フォローを解除"
          }.to change { Relationship.count }.by(-1)
          expect(page).to have_content "#{other_users[1].name}のフォローを解除しました"
          expect(page).to have_button "フォローする"
          expect(page).to have_no_button "フォローを解除"
        end
      end
    end

    describe "#edit" do
      background do
        visit root_path
        within ".header_nav" do
          click_link "設定"
        end
      end

      scenario "レスポンスのステータスが正しいこと" do
        expect(page).to have_http_status(200)
      end

      scenario "正常にアップデートが機能していること" do
        fill_in("user_name", with: "tarou")
        click_on "更新"
        expect(current_path).to eq user_path(user.id)
        expect(page).to have_content "ユーザー情報を更新しました"
        expect(user.reload.name).to eq "tarou"
      end

      scenario "アップデートに失敗したときの振る舞い" do
        fill_in("user_name", with: "")
        click_on "更新"
        expect(page).to have_content "更新に失敗しました。入力内容に不備がないかご確認ください。"
      end

      scenario "アカウント削除ボタンが正常に機能していること" do
        expect{
          click_on "アカウント削除"
        }.to change { User.count }.by(-1)
        expect(current_path).to eq root_path
        expect(page).to have_content "アカウントを削除しました"
      end

      scenario "戻るのリンクが正常に機能していること" do
        click_on "戻る"
        expect(current_path).to eq root_path
      end

      scenario "パスワード変更のリンクが正常に機能していること" do
        click_on "パスワードを変更する"
        expect(current_path).to eq edit_user_registration_path
      end
    end

    describe "#destroy" do
      scenario "アカウントを削除できること" do
        expect{ user.destroy }.to change(User, :count).by(-1)
      end
    end

    describe "#user_posts" do
      background do
        visit user_posts_user_path(user.id)
      end

      scenario "レスポンスのステータスが正しいこと" do
        expect(page).to have_http_status(200)
      end

      scenario "ユーザーが投稿した情報が表示されていること" do
        expect(page).to have_content board.title
        expect(page).to have_no_content board2.title
      end
    end

    describe "#favorites" do
      background do
        visit favorites_user_path(user.id)
      end

      scenario "レスポンスのステータスが正しいこと" do
        expect(page).to have_http_status(200)
      end

      scenario "いいねしている投稿が表示されていること" do
        expect(page).to have_content favorite_board.board.title
        expect(page).to have_no_content not_favorite_board.board.title
      end
    end

    describe "#followings" do
      background do
        visit followings_user_path(user.id)
      end

      scenario "レスポンスのステータスが正しいこと" do
        expect(page).to have_http_status(200)
      end

      scenario "正常な値が取得できていること" do
        expect(page).to have_content follow.follow.name
        expect(page).to have_content follow.follow.introduction
      end

      scenario "フォローしているユーザー情報のみ表示されていること" do
        expect(page).to have_content follow.follow.name
        expect(page).to have_no_content unfollow.follow.name
      end

      scenario "フォロー一覧へのリンクが正常に機能していること" do
        click_on "フォロー中"
        expect(current_path).to eq followings_user_path(user.id)
      end

      scenario "フォロワー一覧へのリンクが正常に機能していること" do
        click_on "フォロワー"
        expect(current_path).to eq followers_user_path(user.id)
      end

      scenario "ユーザー詳細ページへのリンクが正常に機能していること" do
        click_on "戻る"
        expect(current_path).to eq user_path(user.id)
      end

      scenario "フォロー解除ボタンが表示されていること" do
        expect(page).to have_button "フォローを解除"
      end

      scenario "フォロー解除ボタンをクリックした際の振る舞い" do
        expect{
          click_on "フォローを解除"
        }.to change { Relationship.count }.by(-1)
        expect(page).to have_content "#{other_users[1].name}のフォローを解除しました"
        expect(page).to have_button "フォローする"
        expect(page).to have_no_button "フォローを解除"
      end
    end

    describe "#followers" do
      background do
        visit followers_user_path(user.id)
      end

      scenario "レスポンスのステータスが正しいこと" do
        expect(page).to have_http_status(200)
      end

      scenario "フォロワーの情報のみ表示されていること" do
        expect(page).to have_content follower.user.name
        expect(page).to have_no_content not_follower.user.name
      end

      scenario "フォローボタンが表示されていること" do
        expect(page).to have_button "フォローする"
      end

      scenario "フォローボタンをクリックした際の振る舞い" do
        expect{
          click_on "フォローする"
        }.to change { Relationship.count }.by(1)
        expect(page).to have_content "#{other_users[0].name}をフォローしました"
        expect(page).to have_button "フォローを解除"
        expect(page).to have_no_button "フォローする"
      end
    end
  end
end
