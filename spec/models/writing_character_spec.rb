require "rails_helper"

RSpec.describe WritingCharacter, type: :model do
  it "requires only a name and book" do
    character = build(:writing_character, name: "  Marc  ")
    expect(character).to be_valid
    expect(character.name).to eq("Marc")
    character.name = " "
    expect(character).not_to be_valid
  end

  it "validates optional role and status" do
    expect(build(:writing_character, role: "invalid")).not_to be_valid
    expect(build(:writing_character, status: "invalid")).not_to be_valid
    expect(build(:writing_character, role: "", status: "")).to be_valid
  end

  it "stores all optional profile fields" do
    fields = described_class::PROFILE_SECTIONS.values.flat_map(&:keys).index_with { "Informação narrativa" }
    character = create(:writing_character, **fields)
    expect(character.reload.attributes.symbolize_keys.slice(*fields.keys)).to eq(fields)
  end

  it "rejects unsupported and oversized reference images" do
    character = build(:writing_character)
    character.reference_image.attach(io: StringIO.new("text"), filename: "reference.txt", content_type: "text/plain")
    expect(character).not_to be_valid
    character.reference_image.attach(io: StringIO.new("x" * (5.megabytes + 1)), filename: "reference.png", content_type: "image/png", identify: false)
    expect(character).not_to be_valid
    expect(character.errors[:reference_image]).to include("deve ter no máximo 5 MB")
  end

  it "deletes incoming and outgoing relationships when destroyed" do
    character = create(:writing_character)
    other = create(:writing_character, writing_book: character.writing_book)
    WritingRelationship.create!(writing_book: character.writing_book, source_character: character, target_character: other, relation_type: "friendship")
    WritingRelationship.create!(writing_book: character.writing_book, source_character: other, target_character: character, relation_type: "distrust")
    expect { character.destroy! }.to change(WritingRelationship, :count).by(-2)
  end
end
