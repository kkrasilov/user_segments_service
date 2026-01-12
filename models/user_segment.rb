class UserSegment < ActiveRecord::Base
  belongs_to :user
  belongs_to :segment

  validates :user_id, presence: true
  validates :segment_id, presence: true
  validates :user_id, uniqueness: { scope: :segment_id, message: "already has this segment" }
end
