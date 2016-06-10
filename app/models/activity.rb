class Activity < ActiveRecord::Base
  belongs_to :user
  has_many :points, dependent: :destroy
  has_many :comments, dependent: :destroy
  validates :user_id, presence: true
    
  #validates :image, presence: true

  # validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  #validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/


end