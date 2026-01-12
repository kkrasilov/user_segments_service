class Segment < ActiveRecord::Base
  has_many :user_segments, dependent: :destroy
  has_many :users, through: :user_segments

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true
  validates :slug, format: { with: /\A[A-Z0-9_]+\z/, message: "only allows uppercase letters, numbers and underscores" }

  before_update :set_updated_at

  def assign_to_random_users(percent)
    return unless percent > 0 && percent <= 100

    total_users = User.count
    users_to_assign = (total_users * percent / 100.0).round

    return if users_to_assign == 0

    # Выбираем случайных пользователей, которые еще не имеют этого сегмента
    selected_users = User.where.not(id: self.users.pluck(:id))
                         .order("RANDOM()")
                         .limit(users_to_assign)

    selected_users.each do |user|
      UserSegment.create(user: user, segment: self)
    end
  end

  private

  def set_updated_at
    self.updated_at = Time.now
  end
end
