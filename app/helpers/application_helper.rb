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
end
