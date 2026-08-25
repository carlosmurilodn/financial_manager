import "@hotwired/turbo-rails"
import "./select2_init"
import "select2/dist/css/select2.css"
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
import "./income_form"
import "./financial_goal_form"
import "./calendar_tabs"
import "./flash_messages"
import "./color_select_preview"
import "./mobile_filter_accordion"

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/service-worker.js")
  })
}
