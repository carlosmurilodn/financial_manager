class PhilosophicalWorkshopController < ApplicationController
  def index
    @philosophers_count = current_user.philosophical_workshop_philosophers.count
    @concepts_count = current_user.philosophical_workshop_concepts.count
  end
end
