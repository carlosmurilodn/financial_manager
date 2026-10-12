class TacoCatalogRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :taco }
end
