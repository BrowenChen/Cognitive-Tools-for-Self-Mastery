module ApplicationHelper
  def alert_for(flash_type)
    { success: 'alert-success',
      error: 'alert-danger',
      alert: 'alert-warning',
      notice: 'alert-info'
    }[flash_type.to_sym] || flash_type.to_s
  end

  def can_work_on_activity?(condition, activity, next_activity)
    condition != 'forced' || activity == next_activity
  end

  def next_activity_by_points
    return if @activities.blank? || @current_point_values.blank?
    return @next_activity_by_points if defined?(@next_activity_by_points)

    @next_activity_by_points = @activities.min_by do |activity|
      activity.is_completed? ? Float::INFINITY : @current_point_values[activity.a_id-1]
    end if @activities.detect { |activity| !activity.is_completed? }
  end

  def allow_generate_bonus_code?
    current_user.monetary? ||
    ((current_user.points? || current_user.constant_points? || current_user.control? || current_user.advice? || current_user.forced?) && current_user.finished_all_activities)
  end
end
