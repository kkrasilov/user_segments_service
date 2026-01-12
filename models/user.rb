class User < ActiveRecord::Base
  has_many :user_segments, dependent: :destroy
  has_many :segments, through: :user_segments
end
