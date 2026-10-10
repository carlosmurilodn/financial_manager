require "digest"

class WritingRelationship < ApplicationRecord
  TYPES = {
    "friendship" => "Amizade",
    "best_friendship" => "Melhor amizade",
    "romance" => "Relação romântica",
    "attraction" => "Atração",
    "unrequited_love" => "Amor não correspondido",
    "marriage" => "Casamento",
    "former_romance" => "Ex-relacionamento",
    "kinship" => "Parentesco",
    "parent_child" => "Relação parental",
    "siblings" => "Irmãos",
    "professional" => "Relação profissional",
    "partnership" => "Parceria",
    "mentorship" => "Mentoria",
    "protection" => "Proteção",
    "admiration" => "Admiração",
    "trust" => "Confiança",
    "loyalty" => "Lealdade",
    "alliance" => "Aliança",
    "rivalry" => "Rivalidade",
    "enmity" => "Inimizade",
    "distrust" => "Desconfiança",
    "jealousy" => "Ciúme",
    "resentment" => "Ressentimento",
    "manipulation" => "Manipulação",
    "dependency" => "Dependência",
    "other" => "Outro"
  }.freeze

  belongs_to :writing_book
  belongs_to :source_character, class_name: "WritingCharacter", inverse_of: :outgoing_relationships
  belongs_to :target_character, class_name: "WritingCharacter", inverse_of: :incoming_relationships

  before_validation :normalize_relationship
  validates :relation_type, inclusion: { in: TYPES.keys }
  validates :fingerprint, uniqueness: { scope: :writing_book_id, message: "já corresponde a uma relação idêntica cadastrada" }
  validate :characters_from_same_book
  validate :different_characters

  def type_label
    TYPES[relation_type]
  end

  private

  def normalize_relationship
    self.description = description.to_s.strip.presence
    self.current_situation = current_situation.to_s.strip.presence
    self.fingerprint = Digest::SHA256.hexdigest([ source_character_id, target_character_id, relation_type, description, current_situation ].to_json)
  end

  def characters_from_same_book
    %i[source_character target_character].each do |field|
      character = public_send(field)
      errors.add(field, "deve pertencer ao mesmo livro") if character && character.writing_book_id != writing_book_id
    end
  end

  def different_characters
    errors.add(:target_character, "deve ser diferente do personagem de origem") if source_character_id.present? && source_character_id == target_character_id
  end
end
