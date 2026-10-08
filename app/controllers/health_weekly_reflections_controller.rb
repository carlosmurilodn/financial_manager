class HealthWeeklyReflectionsController < HealthPersonalRecordsController
  private

  def set_area
    @area = "weekly"
  end

  def date_field
    :week_start
  end

  def collection
    current_user.health_weekly_reflections
  end

  def record_params
    params.require(:health_weekly_reflection).permit(*HealthWeeklyReflection::TEXT_FIELDS, :routine_satisfaction, weekly_needs: [])
  end
end
