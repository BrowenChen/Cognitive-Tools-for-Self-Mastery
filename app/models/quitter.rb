class Quitter < ActiveRecord::Base
  belongs_to :user, inverse_of: :quitters

  scope :recent, -> { order('created_at DESC') }
end
