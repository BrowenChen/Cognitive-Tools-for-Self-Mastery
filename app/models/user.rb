class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :activities, dependent: :destroy, inverse_of: :user
  has_many :comments, dependent: :destroy
  has_many :answers, dependent: :destroy, inverse_of: :user

  attr_accessor :login

  validates :user_name, presence: true, length: { minimum: 4, maximum: 16 }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.find_first_by_auth_conditions(warden_conditions)
   conditions = warden_conditions.dup
   if login = conditions.delete(:login)
     where(conditions).where(["user_name = :value", { :value => login }]).first
   else
     where(conditions).first
   end
  end

  #dont require email
  def email_required?
    false
  end

  def email_changed?
    false
  end
end
