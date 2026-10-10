require "rails_helper"

RSpec.describe "Philosophical workshop interface", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  {
    philosophers: { name: "Sócrates" },
    concepts: { title: "Conhecimento", kind: "concept", description: "Descrição" },
    thoughts: { title: "Reflexão", central_idea: "Ideia central" },
    insights: { content: "Uma percepção" },
    questions: { question: "O que é conhecimento?" }
  }.each do |resource, attributes|
    it "keeps #{resource} forms and details within the existing visual patterns" do
      collection = "philosophical_workshop_#{resource}"
      singular = collection.singularize
      collection_path = public_send("#{collection}_path")

      get public_send("new_#{singular}_path")
      expect(response).to have_http_status(:ok)
      page = Nokogiri::HTML(response.body)
      expect(page.at_css(".app-form-page.writing-studio > .app-breadcrumbs")).to be_present
      expect(page.at_css(".app-form-page__actions .app-btn--outline .material-symbols-rounded").text).to eq("close")
      expect(page.at_css(".app-sidebar__nav a[href='#{philosophical_workshop_path}']")["class"].split).to include("active-menu")

      post collection_path, params: { singular => attributes }
      expect(response).to have_http_status(:see_other)
      record_path = URI(response.location).request_uri

      get record_path
      expect(response).to have_http_status(:ok)
      page = Nokogiri::HTML(response.body)
      expect(page.css(".writing-detail__title .material-symbols-rounded")).not_to be_empty
      expect(page.at_css('form[data-turbo-confirm]')).to be_present

      get "#{record_path}/edit"
      expect(response).to have_http_status(:ok)
      page = Nokogiri::HTML(response.body)
      expect(page.at_css(".app-form-page.writing-studio > .app-breadcrumbs")).to be_present
      expect(page.at_css('.app-breadcrumbs [aria-current="page"]').text).to eq("Editar")

      patch record_path, params: { singular => attributes }
      expect(response).to have_http_status(:see_other)
      follow_redirect!
      expect(Nokogiri::HTML(response.body).at_css(".app-alert--success")).to be_present

      get collection_path, params: { query: "termo inexistente", title: "termo inexistente", name: "termo inexistente" }
      expect(response).to have_http_status(:ok)
      expect(Nokogiri::HTML(response.body).at_css(".writing-empty")).to be_present

      delete record_path
      expect(response).to redirect_to(collection_path)
    end
  end
end
