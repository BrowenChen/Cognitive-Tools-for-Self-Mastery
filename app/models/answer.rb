class Answer < ActiveRecord::Base
  belongs_to :activity, inverse_of: :answers
  belongs_to :user, inverse_of: :answers

  validate :validate_long_answer

  private

  def validate_long_answer
    return if answer && answer.split.size >= QUESTION[answer.activity.a_id][1]

    errors.add(:answer, 'is not long enough')
  end
end
