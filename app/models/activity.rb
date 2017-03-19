class Activity < ActiveRecord::Base
  has_many :comments, dependent: :destroy
  has_many :points, dependent: :destroy
  has_many :answers, dependent: :destroy, inverse_of: :activity

  belongs_to :user, inverse_of: :activities

  validates :user_id, presence: true
end
