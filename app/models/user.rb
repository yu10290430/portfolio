class User < ApplicationRecord
  MAX_RANK_LIMIT = 3

  validates :name, presence: true
  has_many :boards, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_one_attached :avatar
  has_many :relationships, dependent: :destroy
  has_many :followings, through: :relationships, source: :follow
  has_many :reverse_of_relationships, class_name: 'Relationship', foreign_key: 'follow_id', dependent: :destroy
  has_many :followers, through: :reverse_of_relationships, source: :user
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  before_create :default_image

  def default_image
    if !avatar.attached?
      avatar.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'user_none.jpeg')),
                    filename: 'default-image.jpeg', content_type: 'image/jpeg')
    end
  end

  def self.guest
    find_or_create_by(email: "test@com", name: "テストユーザー") do |user|
      user.password = "password"
    end
  end

  def follow(other_user)
    unless self == other_user
      relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    followings.include?(other_user)
  end

  def self.create_user_ranks
    User.find(Relationship.group(:follow_id).order('count(follow_id) desc').limit(MAX_RANK_LIMIT).pluck(:follow_id))
  end
end
