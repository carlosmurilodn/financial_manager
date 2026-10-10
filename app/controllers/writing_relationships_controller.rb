class WritingRelationshipsController < ApplicationController
  before_action :set_context
  before_action :set_relationship, only: %i[edit update destroy]

  def new
    @relationship = @book.writing_relationships.new(source_character: @character, relation_type: "other")
  end

  def create
    @relationship = @book.writing_relationships.new(relationship_params)
    persist_relationship(:new) { @relationship.save }
  end

  def edit
  end

  def update
    @relationship.assign_attributes(relationship_params)
    persist_relationship(:edit) { @relationship.save }
  end

  def destroy
    @relationship.destroy!
    redirect_to character_path, notice: "Relacionamento excluído!", status: :see_other
  end

  private

  def set_context
    @book = current_user.writing_books.find(params[:writing_book_id])
    @character = @book.writing_characters.find(params[:writing_character_id])
  end

  def set_relationship
    @relationship = @character.relationships.find(params[:id])
  end

  def relationship_params
    permitted = params.require(:writing_relationship).permit(:source_character_id, :target_character_id, :relation_type, :description, :current_situation)
    %i[source_character_id target_character_id].each do |field|
      @book.writing_characters.find(permitted[field]) if permitted[field].present?
    end
    permitted
  end

  def persist_relationship(template)
    unless [ @relationship.source_character_id, @relationship.target_character_id ].include?(@character.id)
      @relationship.errors.add(:base, "O relacionamento deve incluir o personagem desta ficha.")
      return render template, status: :unprocessable_content
    end
    if yield
      redirect_to character_path, notice: "Relacionamento salvo!", status: :see_other
    else
      render template, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotUnique
    @relationship.errors.add(:base, "Relacionamento idêntico já cadastrado.")
    render template, status: :unprocessable_content
  end

  def character_path
    writing_book_writing_character_path(@book, @character, anchor: "relacionamentos")
  end
end
