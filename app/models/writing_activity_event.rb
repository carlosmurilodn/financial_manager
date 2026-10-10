class WritingActivityEvent < ApplicationRecord
  OPERATIONS = { "create" => "Criação De Texto", "edit" => "Edição", "destroy" => "Exclusão De Texto",
    "move" => "Movimentação De Cena", "restore" => "Restauração", "import" => "Importação" }.freeze
  belongs_to :writing_book
  validates :operation, inclusion: { in: OPERATIONS.keys }
  validates :chapter_title, :occurred_at, presence: true

  def readonly?
    persisted?
  end

  def textual?
    operation != "move"
  end
end
