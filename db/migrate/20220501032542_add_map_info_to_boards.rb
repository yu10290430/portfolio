class AddMapInfoToBoards < ActiveRecord::Migration[6.1]
  def change
    add_column :boards, :latitude, :float
    add_column :boards, :longitude, :float
  end
end
