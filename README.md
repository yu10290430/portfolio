１.Fishing Shareについて
  "Fishing Share"は、釣り情報を共有するサービスです。
  ⚪︎作成した理由
    釣りが趣味で、他の釣り人達と情報を共有し、より釣りを楽しめるようなサービスを作りたいという思いから本サービスを開発しました。
  ⚪︎使用方法
    まず、新規登録ページにてユーザー情報を登録してください。（テストアカウントでログインする場合は省略可能）ログイン後は、サイトトップページにて新規投稿が可能です。投稿は位置情報付きでアップされるため、新たな釣り場を見つたり、現地の詳しい情報についても共有することが出来ます。また、いいね機能や、ユーザー間でのフォロー機能がついており、いいねした投稿や、フォローしたユーザーについては、ユーザー詳細ページにて確認することが出来ます。サイトトップページには投稿のいいね獲得数、フォロワー数のランキングも表示されている為、情報共有だけでなく、ランキング上位を目指す等、本サービスを楽しむことが出来る様に工夫しました。
　  また、レスポンシブ対応しているのでスマホからご確認いただけます。

２.使用技術
・Ruby 3.0.3
・Ruby on Rails 6.1.5
・MySQL 8.0
・Docker/Docker-compose
・Heroku
・AWS S3
・RSpec
・Google Maps API

3.テーブル
  ⚪︎boards
    投稿に関するデータを保存
  ⚪︎users
    ユーザーデータを保存
  ⚪︎favorites
    boards,usersの中間テーブル。いいね機能に関するデータを保存しており、boards,usersの各テーブルと「一対多」(board対favorites)(user対favorites)
    でアソシエーションしています。
  ⚪︎relationships
    usersの中間テーブル。フォロー機能に関するデータを保存しており、「多対多」(user対user)と「一対多」(user対relationships)の形でアソシエーションしています。
    user_id(フォローする側のuserデータ),follow_id(フォローされた側のuserデータ)として保存されています。

4.機能一覧
・ユーザー登録、ログイン機能(devise)
・投稿機能
　　⚪︎画像投稿（ActiveStorage)
　　⚪︎住所に基づく位置情報保存（geocoder)
・いいね機能
　　⚪︎ランキング機能（投稿に対するいいね数）
・フォロー機能
　　⚪︎ランキング機能（フォロワー数）
・検索機能
・ページネーション機能(kaminari)
・RSpec
  　⚪︎単体テスト(model)
    ⚪︎統合テスト(feature)
