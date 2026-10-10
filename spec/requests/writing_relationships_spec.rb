require "rails_helper"

RSpec.describe "Writing relationships", type: :request do
  let(:user) { create(:user) }
  let(:book) { create(:writing_book, user: user) }
  let(:source) { create(:writing_character, writing_book: book, name: "Marc") }
  let(:target) { create(:writing_character, writing_book: book, name: "Teresa") }
  let(:attributes) { { source_character_id: source.id, target_character_id: target.id, relation_type: "friendship", description: "Marc confia em Teresa" } }
  before { sign_in user }

  def collection_path(character = source)
    writing_book_writing_character_writing_relationships_path(book, character)
  end

  def member_path(relationship, character = source)
    writing_book_writing_character_writing_relationship_path(book, character, relationship)
  end

  it "creates directional relationships visible in both sheets and edits from the target" do
    post collection_path, params: { writing_relationship: attributes }
    expect(response).to have_http_status(:see_other)
    relationship = book.writing_relationships.last
    [ source, target ].each do |character|
      get writing_book_writing_character_path(book, character)
      expect(response.body).to include("Marc confia em Teresa", "Amizade")
    end
    get edit_writing_book_writing_character_writing_relationship_path(book, target, relationship)
    expect(response).to have_http_status(:ok)
    patch member_path(relationship, target), params: { writing_relationship: attributes.merge(current_situation: "Abalada") }
    expect(relationship.reload.current_situation).to eq("Abalada")
    expect(relationship.source_character).to eq(source)
    post collection_path(target), params: { writing_relationship: attributes.merge(source_character_id: target.id, target_character_id: source.id, relation_type: "distrust") }
    expect(book.writing_relationships.count).to eq(2)
    expect { delete member_path(relationship, target) }.to change(book.writing_relationships, :count).by(-1)
  end

  it "rejects duplicates and self relationships with helpful form errors" do
    post collection_path, params: { writing_relationship: attributes }
    post collection_path, params: { writing_relationship: attributes }
    expect(response).to have_http_status(:unprocessable_content)
    expect(book.writing_relationships.count).to eq(1)
    post collection_path, params: { writing_relationship: attributes.merge(target_character_id: source.id) }
    expect(response).to have_http_status(:unprocessable_content)
  end

  it "rejects characters from other books including books owned by the same user" do
    [ create(:writing_character), create(:writing_character, writing_book: create(:writing_book, user: user)) ].each do |foreign|
      sign_in user
      post collection_path, params: { writing_relationship: attributes.merge(target_character_id: foreign.id) }
      expect(response).to have_http_status(:not_found)
    end
    expect(book.writing_relationships.count).to eq(0)
  end

  it "blocks unrelated and foreign relationship editing and deletion" do
    relationship = book.writing_relationships.create!(attributes)
    unrelated = create(:writing_character, writing_book: book)
    get edit_writing_book_writing_character_writing_relationship_path(book, unrelated, relationship)
    expect(response).to have_http_status(:not_found)
    sign_in user
    patch member_path(relationship, unrelated), params: { writing_relationship: attributes.merge(description: "Intrusão") }
    expect(response).to have_http_status(:not_found)
    sign_in user
    delete member_path(relationship, unrelated)
    expect(response).to have_http_status(:not_found)
    foreign = create(:writing_character)
    sign_in user
    delete writing_book_writing_character_writing_relationship_path(foreign.writing_book, foreign, relationship)
    expect(response).to have_http_status(:not_found)
    expect(relationship.reload.description).to eq("Marc confia em Teresa")
  end

  it "rejects removing the contextual character from the relation" do
    relationship = book.writing_relationships.create!(attributes)
    other = create(:writing_character, writing_book: book)
    patch member_path(relationship), params: { writing_relationship: attributes.merge(source_character_id: other.id) }
    expect(response).to have_http_status(:unprocessable_content)
    expect(relationship.reload.source_character).to eq(source)
  end
end
