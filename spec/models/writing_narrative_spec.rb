require "rails_helper"

RSpec.describe "Writing narrative models", type: :model do
  let(:book) { create(:writing_book) }
  let(:character) { create(:writing_character, writing_book: book) }

  [ WritingPlot, WritingConflict, WritingLocation, WritingOrganization, WritingUniverseRule ].each do |model|
    it "requires only a title or name for #{model}" do
      record = model.new(writing_book: book, model::NAME_FIELD => "  Narrativa  ")
      expect(record).to be_valid
      expect(record.display_name).to eq("Narrativa")
      record[model::NAME_FIELD] = " "
      expect(record).not_to be_valid
    end

    it "persists all narrative fields for #{model}" do
      attrs = model::FIELDS.keys.index_with { "Descrição detalhada" }
      model::OPTIONS.each { |field, options| attrs[field] = options.keys.first }
      record = model.create!(attrs.merge(writing_book: book))
      expect(record.reload.attributes.symbolize_keys.slice(*attrs.keys)).to eq(attrs)
    end
  end

  [ [ WritingPlot, :parent_plot ], [ WritingLocation, :parent_location ] ].each do |model, parent|
    it "rejects self, foreign book and indirect cycles in #{model}" do
      root = model.create!(writing_book: book, model::NAME_FIELD => "Raiz")
      child = model.create!(writing_book: book, model::NAME_FIELD => "Filha", parent => root)
      leaf = model.create!(writing_book: book, model::NAME_FIELD => "Neta", parent => child)
      root.public_send("#{parent}=", leaf)
      expect(root).not_to be_valid
      root.public_send("#{parent}=", root)
      expect(root).not_to be_valid
      foreign = model.create!(writing_book: create(:writing_book), model::NAME_FIELD => "Outra")
      root.public_send("#{parent}=", foreign)
      expect(root).not_to be_valid
    end

    it "preserves child records when deleting a #{model}" do
      root = model.create!(writing_book: book, model::NAME_FIELD => "Raiz")
      child = model.create!(writing_book: book, model::NAME_FIELD => "Filha", parent => root)
      root.destroy!
      expect(child.reload.public_send(parent)).to be_nil
    end
  end

  it "links characters, conflicts and plots and keeps book status unchanged" do
    plot = book.writing_plots.create!(title: "Investigação", status: "planned")
    conflict = book.writing_conflicts.create!(title: "Rivalidade")
    plot.writing_characters << character
    conflict.writing_characters << character
    conflict.writing_plots << plot
    expect(character.writing_plots).to include(plot)
    expect(character.writing_conflicts).to include(conflict)
    expect(plot.writing_conflicts).to include(conflict)
    plot.update!(status: "resolved")
    expect(book.reload.status).to eq("writing")
    expect(conflict.reload.status).to be_nil
  end

  it "rejects cross book join records and duplicate links" do
    plot = book.writing_plots.create!(title: "Trama")
    foreign = create(:writing_character)
    link = WritingPlotCharacter.new(writing_plot: plot, writing_character: foreign)
    expect(link).not_to be_valid
    plot.writing_characters << character
    expect(WritingPlotCharacter.new(writing_plot: plot, writing_character: character)).not_to be_valid
  end

  it "enforces association book boundaries at database level" do
    plot = book.writing_plots.create!(title: "Trama")
    plot.writing_characters << character
    link = plot.writing_plot_characters.first
    foreign = create(:writing_character)
    expect do
      WritingPlotCharacter.transaction(requires_new: true) { link.update_columns(writing_character_id: foreign.id) }
    end.to raise_error(ActiveRecord::InvalidForeignKey)
  end

  it "stores organization roles and rejects foreign locations and members" do
    location = book.writing_locations.create!(name: "Delegacia")
    organization = book.writing_organizations.create!(name: "Polícia", writing_location: location)
    membership = organization.writing_organization_memberships.create!(writing_character: character, role: "Investigador")
    expect(membership.reload.role).to eq("Investigador")
    expect(character.writing_organizations).to include(organization)
    expect(location.writing_organizations).to include(organization)
    organization.writing_location = WritingLocation.create!(writing_book: create(:writing_book), name: "Outra")
    expect(organization).not_to be_valid
    expect(organization.writing_organization_memberships.new(writing_character: create(:writing_character))).not_to be_valid
  end

  it "removes association records when deleting characters and narrative entities" do
    plot = book.writing_plots.create!(title: "Trama")
    conflict = book.writing_conflicts.create!(title: "Conflito")
    organization = book.writing_organizations.create!(name: "Organização")
    plot.writing_characters << character
    conflict.writing_characters << character
    conflict.writing_plots << plot
    organization.writing_characters << character
    character.destroy!
    expect(WritingPlotCharacter.count).to eq(0)
    expect(WritingConflictCharacter.count).to eq(0)
    expect(WritingOrganizationMembership.count).to eq(0)
    plot.destroy!
    expect(WritingConflictPlot.count).to eq(0)
    expect(conflict.reload).to be_present
  end

  it "preserves organizations after deleting a location and removes all records with a book" do
    location = book.writing_locations.create!(name: "Local")
    organization = book.writing_organizations.create!(name: "Organização", writing_location: location)
    location.destroy!
    expect(organization.reload.writing_location).to be_nil
    book.writing_plots.create!(title: "Trama").writing_characters << character
    book.writing_conflicts.create!(title: "Conflito").writing_characters << character
    organization.writing_characters << character
    book.writing_universe_rules.create!(title: "Regra")
    book.destroy!
    [ WritingPlot, WritingConflict, WritingOrganization, WritingUniverseRule, WritingOrganizationMembership ].each { |model| expect(model.count).to eq(0) }
  end

  it "validates location image type and size" do
    location = book.writing_locations.new(name: "Cidade")
    location.reference_image.attach(io: StringIO.new("text"), filename: "file.txt", content_type: "text/plain")
    expect(location).not_to be_valid
    location.reference_image.attach(io: StringIO.new("x" * (5.megabytes + 1)), filename: "large.png", content_type: "image/png", identify: false)
    expect(location).not_to be_valid
  end
  it "rechecks a stale hierarchy inside the serialization lock" do
    root = book.writing_plots.create!(title: "Raiz")
    child = book.writing_plots.create!(title: "Filha")
    stale = WritingPlot.find(root.id)
    stale.parent_plot = child
    expect(stale).to be_valid
    child.update!(parent_plot: root)
    expect { stale.save!(validate: false) }.to raise_error(ActiveRecord::RecordInvalid)
    expect(root.reload.parent_plot).to be_nil
  end
end
