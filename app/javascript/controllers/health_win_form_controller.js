import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["description"]

  useSuggestion(event) {
    this.descriptionTarget.value = event.currentTarget.textContent.trim()
    this.descriptionTarget.dispatchEvent(new Event("input", { bubbles: true }))
    this.descriptionTarget.focus()
  }
}
