require "rails_helper"

RSpec.describe "Writing characters", type: :request do
  let(:user) { create(:user) }
  let(:book) { create(:writing_book, user: user) }
  let(:character) { create(:writing_character, writing_book: book, name: "Marc", role: "protagonist", status: "active") }
  before { sign_in user }

  it "creates, edits, displays and deletes a character" do
    get new_writing_book_writing_character_path(book)
    expect(response).to have_http_status(:ok)
    expect do
      post writing_book_writing_characters_path(book), params: { writing_character: { name: "Teresa", fears: "Escuridão" } }
    end.to change(book.writing_characters, :count).by(1)
    created = book.writing_characters.last
    expect(response).to redirect_to(writing_book_writing_character_path(book, created))
    get edit_writing_book_writing_character_path(book, created)
    expect(response).to have_http_status(:ok)
    patch writing_book_writing_character_path(book, created), params: { writing_character: { name: "Teresa Silva", goals: "Salvar Marc" } }
    expect(created.reload.goals).to eq("Salvar Marc")
    get writing_book_writing_character_path(book, created)
    expect(response.body).to include("Salvar Marc", "Escuridão", "Características físicas", "História pessoal", "Desenvolvimento narrativo")
    expect(response.body).to include("data-turbo-confirm")
    expect do
      delete writing_book_writing_character_path(book, created)
    end.to change(book.writing_characters, :count).by(-1)
  end

  it "renders validation errors without creating an empty character" do
    post writing_book_writing_characters_path(book), params: { writing_character: { name: " " } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Revise os campos abaixo")
  end

  it "searches by name and applies role and status filters within the book" do
    character
    create(:writing_character, writing_book: book, name: "Teresa", role: "antagonist", status: "inactive")
    create(:writing_character, name: "Marc de outro livro")
    get writing_book_writing_characters_path(book), params: { name: "Marc", role: "protagonist", status: "active" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Marc")
    expect(response.body).not_to include("Teresa", "Marc de outro livro")
    get writing_book_writing_characters_path(book), params: { name: "%" }
    expect(response.body).to include("Nenhum personagem encontrado")
  end

  it "uploads, serves privately, replaces and removes an image" do
    upload = Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/character.png"), "image/png")
    post writing_book_writing_characters_path(book), params: { writing_character: { name: "Com imagem", reference_image: upload } }
    created = book.writing_characters.last
    expect(created.reference_image).to be_attached
    first_blob = created.reference_image.blob.id
    get image_writing_book_writing_character_path(book, created)
    expect(response).to have_http_status(:ok)
    expect(response.headers["Cache-Control"]).to include("private", "no-store")
    patch writing_book_writing_character_path(book, created), params: { writing_character: { reference_image: Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/character.png"), "image/png"), remove_reference_image: "1" } }
    expect(created.reload.reference_image.blob.id).not_to eq(first_blob)
    patch writing_book_writing_character_path(book, created), params: { writing_character: { name: "Preservada", reference_image: "" } }
    expect(created.reload.reference_image).to be_attached
    patch writing_book_writing_character_path(book, created), params: { writing_character: { remove_reference_image: "1" } }
    expect(created.reload.reference_image).not_to be_attached
  end

  it "blocks foreign books and foreign characters on all member actions" do
    foreign = create(:writing_character)
    [ writing_book_writing_characters_path(foreign.writing_book), new_writing_book_writing_character_path(foreign.writing_book), writing_book_writing_character_path(foreign.writing_book, foreign), image_writing_book_writing_character_path(foreign.writing_book, foreign), edit_writing_book_writing_character_path(foreign.writing_book, foreign), writing_book_writing_character_path(book, foreign) ].each do |path|
      sign_in user
      get path
      expect(response).to have_http_status(:not_found)
    end
    sign_in user
    patch writing_book_writing_character_path(foreign.writing_book, foreign), params: { writing_character: { name: "Intrusão" } }
    expect(response).to have_http_status(:not_found)
    sign_in user
    delete writing_book_writing_character_path(foreign.writing_book, foreign)
    expect(response).to have_http_status(:not_found)
    sign_in user
    post writing_book_writing_characters_path(foreign.writing_book), params: { writing_character: { name: "Intrusão" } }
    expect(response).to have_http_status(:not_found)
    expect(foreign.reload.name).not_to eq("Intrusão")
  end

  it "ignores ownership injection and keeps an existing image after invalid updates" do
    character.reference_image.attach(io: File.open(Rails.root.join("spec/fixtures/files/character.png")), filename: "character.png", content_type: "image/png")
    other_book = create(:writing_book)
    patch writing_book_writing_character_path(book, character), params: { writing_character: { name: "Atualizado", writing_book_id: other_book.id, user_id: other_book.user_id } }
    expect(character.reload.writing_book).to eq(book)
    patch writing_book_writing_character_path(book, character), params: { writing_character: { name: "", remove_reference_image: "1" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(character.reload.reference_image).to be_attached
  end

  it "paginates cards without dropping filters" do
    11.times { |n| create(:writing_character, writing_book: book, name: "Pessoa #{n}", role: "secondary") }
    get writing_book_writing_characters_path(book), params: { role: "secondary", per_page: 10, page: 2 }
    expect(response).to have_http_status(:ok)
    expect(response.body.scan('class="app-panel writing-character-card"').size).to eq(1)
    expect(response.body).to include("role=secondary", "page=1")
  end

  it "requires authentication" do
    character
    sign_out user
    get writing_book_writing_characters_path(book)
    expect(response).to redirect_to(new_user_session_path)
    get image_writing_book_writing_character_path(book, character)
    expect(response).to redirect_to(new_user_session_path)
  end
end
