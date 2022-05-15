class Board < ApplicationRecord
  validates :title, presence: true, length: { maximum: 20 }
  validates :weather, presence: true
  validates :address, presence: true
  validates :kind, presence: true
  validates :date, presence: true
  validates :tide, presence: true
  validates :result, presence: true, numericality: true
  validates :body, presence: true, length: { maximum: 200 }
  validate :start_check

  belongs_to :user
  has_many :favorites, dependent: :destroy
  has_many_attached :images
  geocoded_by :address
  after_validation :geocode, if: :address_changed?

  def start_check
    return if date.blank?
    errors.add(:date, "は本日以前のものを選択してください") if date > Date.today
  end

  def self.search(keyword)
    return Board.all.order(created_at: :desc) unless keyword
    Board.where(['title LIKE ? OR body LIKE ? OR address LIKE ? OR kind LIKE ?', "%#{keyword}%", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%"])
  end

  def favorited_by?(user)
    favorites.where(user_id: user.id).exists?
  end

  def self.create_ranks
    Board.find(Favorite.group(:board_id).order('count(board_id) desc').limit(3).pluck(:board_id))
  end
end
