module ApplicationHelper
  def alert_for(flash_type)
    { success: 'alert-success',
      error: 'alert-danger',
      alert: 'alert-warning',
      notice: 'alert-info'
    }[flash_type.to_sym] || flash_type.to_s
  end

  def has_pending_activities?(list)
    list.detect { |activity| !activity.is_completed? }
  end

  def next_activity_by_points(list, points)
    list.max_by { |activity| activity.is_completed? ? -Float::INFINITY : points[activity.a_id-1] }
  end
end
