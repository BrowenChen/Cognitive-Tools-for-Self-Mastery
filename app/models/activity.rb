class Activity < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  has_many :comments, dependent: :destroy
  #validates :image, presence: true

  has_attached_file :image
  # validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/


end
