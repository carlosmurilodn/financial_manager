import "@hotwired/turbo-rails"
import "bootstrap"
import "./stylesheets/application.bootstrap.scss"
import "../assets/stylesheets/date_picker.css"
import "../assets/stylesheets/modals.css"
import "./date_picker"
import "./utils"
import "./modal_required_fields"
import "./modal_turbo"
import "./confirm_dialog"
import "./dashboard_category_items"
import "./expense_form"
import "./financial_goal_form"
import "./calendar_tabs"
import "./passkey_test"

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/service-worker.js")
  })
}
