require "rails_helper"

RSpec.describe WritingRelationship, type: :model do
  let(:book) { create(:writing_book) }
  let(:source) { create(:writing_character, writing_book: book) }
  let(:target) { create(:writing_character, writing_book: book) }
  let(:attributes) { { writing_book: book, source_character: source, target_character: target, relation_type: "friendship", description: "Confiança", current_situation: "Estável" } }

  it "appears on both characters while preserving direction" do
    relationship = described_class.create!(attributes)
    expect(source.relationships).to include(relationship)
    expect(target.relationships).to include(relationship)
    expect(relationship.source_character).to eq(source)
    expect(relationship.target_character).to eq(target)
  end

  it "rejects identical duplicates but allows reverse and different relations" do
    described_class.create!(attributes)
    expect(described_class.new(attributes.merge(description: " Confiança "))).not_to be_valid
    expect(described_class.new(attributes.merge(source_character: target, target_character: source))).to be_valid
    expect(described_class.new(attributes.merge(relation_type: "distrust"))).to be_valid
    expect(described_class.new(attributes.merge(description: "Amizade de infância"))).to be_valid
  end

  it "rejects self relationships and references to another book" do
    expect(described_class.new(attributes.merge(target_character: source))).not_to be_valid
    expect(described_class.new(attributes.merge(target_character: create(:writing_character)))).not_to be_valid
  end

  it "keeps the same book invariant at database level" do
    relationship = described_class.create!(attributes)
    foreign_character = create(:writing_character)
    expect do
      described_class.transaction(requires_new: true) { relationship.update_columns(target_character_id: foreign_character.id) }
    end.to raise_error(ActiveRecord::InvalidForeignKey)
  end

  it "removes relationships and characters when a book is deleted" do
    described_class.create!(attributes)
    expect { book.destroy! }.to change(described_class, :count).by(-1).and change(WritingCharacter, :count).by(-2)
  end
end
