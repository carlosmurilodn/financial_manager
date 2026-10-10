require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  it "keeps the workshop and projects navigation active for internal controllers" do
    allow(helper).to receive(:controller_name).and_return("philosophical_workshop_reflections")

    expect(helper.philosophical_workshop_section?).to be(true)
    expect(helper.personal_development_section?).to be(true)
    expect(helper.app_section_brand[:title]).to eq("Projetos")
  end

  it "does not identify unrelated controllers as workshop pages" do
    allow(helper).to receive(:controller_name).and_return("writing_books")

    expect(helper.philosophical_workshop_section?).to be(false)
  end
end
