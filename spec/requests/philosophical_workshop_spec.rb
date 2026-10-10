require "rails_helper"

RSpec.describe "Philosophical workshop", type: :request do
  let(:user) { create(:user) }

  it "requires authentication" do
    get philosophical_workshop_path

    expect(response).to redirect_to(new_user_session_path)
  end

  context "when signed in" do
    before { sign_in user }

    it "opens the initial page with the projects layout and breadcrumbs" do
      get philosophical_workshop_path

      expect(response).to have_http_status(:ok)
      page = Nokogiri::HTML(response.body)
      expect(page.at_css("h1").text).to eq("Oficina Filosófica")
      expect(page.at_css(".app-sidebar--projects")).to be_present
      expect(page.at_css(".app-breadcrumbs a")["href"]).to eq(personal_development_path)
      expect(page.at_css('.app-breadcrumbs [aria-current="page"]').text).to eq("Oficina Filosófica")
    end

    it "highlights a direct sidebar link with a thought icon" do
      get philosophical_workshop_path

      page = Nokogiri::HTML(response.body)
      link = page.at_css(".app-sidebar__nav a[href='#{philosophical_workshop_path}']")
      expect(link["class"].split).to include("active-menu")
      expect(link["aria-current"]).to eq("page")
      expect(link.at_css(".app-nav-link__icon").text).to eq("psychology")
      expect(link.ancestors("details")).to be_empty
      expect(page.at_css(".app-sidebar__nav a[href='#{writing_books_path}']")["class"].split).not_to include("active-menu")
    end

    it "preserves the writing studio highlight on its internal pages" do
      book = create(:writing_book, user: user)
      get writing_book_path(book)

      expect(response).to have_http_status(:ok)
      page = Nokogiri::HTML(response.body)
      expect(page.at_css(".app-sidebar__nav a[href='#{writing_books_path}']")["class"].split).to include("active-menu")
      expect(page.at_css(".app-sidebar__nav a[href='#{philosophical_workshop_path}']")["class"].split).not_to include("active-menu")
    end
  end
end
