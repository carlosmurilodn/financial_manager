import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "quantity"]

  connect() {
    this.update()
  }

  update() {
    this.quantityTarget.disabled = !this.checkboxTarget.checked
  }
}
