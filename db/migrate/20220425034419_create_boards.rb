class CreateBoards < ActiveRecord::Migration[6.1]
  def change
    create_table :boards do |t|
      t.string :title
      t.text :body
      t.references :user, null: false, foreign_key: true
      t.string :weather
      t.string :address
      t.string :kind
      t.date :date
      t.string :tide
      t.string :result

      t.timestamps
    end
  end
end
