require "rails_helper"

RSpec.describe "Writing narrative", type: :request do
  let(:user) { create(:user) }
  let(:book) { create(:writing_book, user: user) }
  before { sign_in user }

  [ WritingPlot, WritingConflict, WritingLocation, WritingOrganization, WritingUniverseRule ].each do |model|
    it "creates, lists, edits, shows and deletes #{model}" do
      get new_polymorphic_path([ book, model ])
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("app-breadcrumbs", "Salvar")
      post polymorphic_path([ book, model ]), params: { model.model_name.param_key => { model::NAME_FIELD => "Narrativa", description: "Texto descritivo" } }
      expect(response).to have_http_status(:see_other)
      record = model.last
      get polymorphic_path([ book, model ]), params: { query: "Narrativa" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Narrativa")
      get edit_polymorphic_path([ book, record ])
      expect(response).to have_http_status(:ok)
      patch polymorphic_path([ book, record ]), params: { model.model_name.param_key => { model::NAME_FIELD => "Alterada" } }
      expect(record.reload.display_name).to eq("Alterada")
      get polymorphic_path([ book, record ])
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Texto descritivo", "data-turbo-confirm")
      expect { delete polymorphic_path([ book, record ]) }.to change(model, :count).by(-1)
    end

    it "shows validation errors for #{model}" do
      post polymorphic_path([ book, model ]), params: { model.model_name.param_key => { model::NAME_FIELD => "" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Revise os campos abaixo")
    end

    it "blocks all foreign book actions for #{model}" do
      foreign_book = create(:writing_book)
      record = model.create!(writing_book: foreign_book, model::NAME_FIELD => "Privada")
      [ polymorphic_path([ foreign_book, model ]), new_polymorphic_path([ foreign_book, model ]), polymorphic_path([ foreign_book, record ]), edit_polymorphic_path([ foreign_book, record ]), polymorphic_path([ book, record ]) ].each do |path|
        sign_in user
        get path
        expect(response).to have_http_status(:not_found)
      end
      sign_in user
      patch polymorphic_path([ foreign_book, record ]), params: { model.model_name.param_key => { model::NAME_FIELD => "Intrusão" } }
      expect(response).to have_http_status(:not_found)
      sign_in user
      delete polymorphic_path([ foreign_book, record ])
      expect(response).to have_http_status(:not_found)
      sign_in user
      post polymorphic_path([ foreign_book, model ]), params: { model.model_name.param_key => { model::NAME_FIELD => "Intrusão" } }
      expect(response).to have_http_status(:not_found)
      expect(record.reload.display_name).to eq("Privada")
    end
  end

  it "links plots and conflicts, renders inverse links on character sheets and ignores ownership injection" do
    character = create(:writing_character, writing_book: book, name: "Teresa")
    foreign_book = create(:writing_book)
    post writing_book_writing_plots_path(book), params: { writing_plot: { title: "Investigação", writing_character_ids: [ character.id ], writing_book_id: foreign_book.id } }
    plot = book.writing_plots.last
    expect(plot.writing_characters).to include(character)
    post writing_book_writing_conflicts_path(book), params: { writing_conflict: { title: "Ameaça", writing_character_ids: [ character.id ], writing_plot_ids: [ plot.id ] } }
    conflict = book.writing_conflicts.last
    expect(conflict.writing_plots).to include(plot)
    get writing_book_writing_character_path(book, character)
    expect(response.body).to include("Investigação", "Ameaça")
    get writing_book_writing_plot_path(book, plot)
    expect(response.body).to include("Teresa", "Ameaça")
  end

  it "rejects cross book associations on every narrative reference" do
    foreign_book = create(:writing_book, user: user)
    foreign_character = create(:writing_character, writing_book: foreign_book)
    foreign_plot = foreign_book.writing_plots.create!(title: "Outra")
    foreign_location = foreign_book.writing_locations.create!(name: "Outro")
    attempts = [
      [ WritingPlot, { title: "Trama", writing_character_ids: [ foreign_character.id ] } ],
      [ WritingPlot, { title: "Trama", parent_plot_id: foreign_plot.id } ],
      [ WritingConflict, { title: "Conflito", writing_plot_ids: [ foreign_plot.id ] } ],
      [ WritingConflict, { title: "Conflito", writing_character_ids: [ foreign_character.id ] } ],
      [ WritingLocation, { name: "Local", parent_location_id: foreign_location.id } ],
      [ WritingOrganization, { name: "Org", writing_location_id: foreign_location.id } ],
      [ WritingOrganization, { name: "Org", writing_organization_memberships_attributes: { "0" => { writing_character_id: foreign_character.id, role: "Líder" } } } ]
    ]
    attempts.each do |model, attrs|
      sign_in user
      post polymorphic_path([ book, model ]), params: { model.model_name.param_key => attrs }
      expect(response).to have_http_status(:not_found)
    end
    expect(book.writing_plots.count).to eq(0)
  end

  it "rolls back association changes when an update fails validation" do
    first = create(:writing_character, writing_book: book)
    second = create(:writing_character, writing_book: book)
    plot = book.writing_plots.create!(title: "Trama")
    plot.writing_characters << first
    patch writing_book_writing_plot_path(book, plot), params: { writing_plot: { title: "", writing_character_ids: [ second.id ] } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(plot.reload.writing_characters).to contain_exactly(first)
  end

  it "rejects circular hierarchy updates" do
    root = book.writing_plots.create!(title: "Raiz")
    child = book.writing_plots.create!(title: "Filha", parent_plot: root)
    patch writing_book_writing_plot_path(book, root), params: { writing_plot: { parent_plot_id: child.id } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(root.reload.parent_plot).to be_nil
  end

  it "adds, edits and removes organizational memberships with roles" do
    character = create(:writing_character, writing_book: book, name: "Marc")
    attrs = { "0" => { writing_character_id: character.id, role: "Diretor", _destroy: "0" } }
    post writing_book_writing_organizations_path(book), params: { writing_organization: { name: "Empresa", writing_organization_memberships_attributes: attrs } }
    expect(response).to have_http_status(:see_other)
    organization = book.writing_organizations.last
    membership = organization.writing_organization_memberships.first
    expect(membership.role).to eq("Diretor")
    get writing_book_writing_organization_path(book, organization)
    expect(response.body).to include("Marc", "Diretor")
    patch writing_book_writing_organization_path(book, organization), params: { writing_organization: { writing_organization_memberships_attributes: { "0" => { id: membership.id, writing_character_id: character.id, role: "Sócio" } } } }
    expect(membership.reload.role).to eq("Sócio")
    patch writing_book_writing_organization_path(book, organization), params: { writing_organization: { writing_organization_memberships_attributes: { "0" => { id: membership.id, _destroy: "1" } } } }
    expect(organization.reload.writing_organization_memberships).to be_empty
  end

  it "uploads, privately serves, replaces and removes location images" do
    image = -> { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/character.png"), "image/png") }
    post writing_book_writing_locations_path(book), params: { writing_location: { name: "Cidade", reference_image: image.call } }
    location = book.writing_locations.last
    expect(location.reference_image).to be_attached
    blob_id = location.reference_image.blob.id
    get image_writing_book_writing_location_path(book, location)
    expect(response).to have_http_status(:ok)
    expect(response.headers["Cache-Control"]).to include("private", "no-store")
    patch writing_book_writing_location_path(book, location), params: { writing_location: { reference_image: image.call, remove_reference_image: "1" } }
    expect(location.reload.reference_image.blob.id).not_to eq(blob_id)
    patch writing_book_writing_location_path(book, location), params: { writing_location: { name: "", remove_reference_image: "1" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(location.reload.reference_image).to be_attached
    patch writing_book_writing_location_path(book, location), params: { writing_location: { name: "Cidade", remove_reference_image: "1" } }
    expect(location.reload.reference_image).not_to be_attached
  end

  it "searches and filters narrative records with pagination and wildcard escaping" do
    11.times { |n| book.writing_plots.create!(title: "Trama #{n}", kind: "main", status: "planned") }
    book.writing_plots.create!(title: "Outra", kind: "secondary", status: "resolved")
    get writing_book_writing_plots_path(book), params: { query: "Trama", kind: "main", status: "planned", per_page: 10, page: 2 }
    expect(response).to have_http_status(:ok)
    expect(response.body.scan('class="app-panel writing-narrative-card"').count).to eq(1)
    expect(response.body).not_to include(">Outra<")
    get writing_book_writing_plots_path(book), params: { query: "%" }
    expect(response.body).to include("Nenhum registro encontrado")
  end

  it "requires authentication and enables the book sections" do
    get writing_book_path(book)
    expect(response.body).to include("Gerenciar tramas e conflitos", "Gerenciar universo e cenários")
    sign_out user
    get writing_book_writing_plots_path(book)
    expect(response).to redirect_to(new_user_session_path)
  end
  it "protects location images from foreign and unauthenticated requests" do
    foreign = WritingLocation.create!(writing_book: create(:writing_book), name: "Privado")
    get image_writing_book_writing_location_path(foreign.writing_book, foreign)
    expect(response).to have_http_status(:not_found)
    sign_in user
    location = book.writing_locations.create!(name: "Local")
    sign_out user
    get image_writing_book_writing_location_path(book, location)
    expect(response).to redirect_to(new_user_session_path)
  end
end
