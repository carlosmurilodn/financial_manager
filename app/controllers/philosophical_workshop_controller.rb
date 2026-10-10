class PhilosophicalWorkshopController < ApplicationController
  def index
    @philosophers_count = current_user.philosophical_workshop_philosophers.count
  end
end
