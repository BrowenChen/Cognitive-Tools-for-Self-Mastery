class Activity < ActiveRecord::Base
  has_many :comments, dependent: :destroy
  has_many :answers, dependent: :destroy, inverse_of: :activity

  belongs_to :user, inverse_of: :activities

  validates :user_id, presence: true

  def question
    QUESTIONS[a_id][0]
  end

  def project
    ACTIVITIES.detect { |activity| activity['Number'] == a_id.to_s }['Goal']
  end
end
