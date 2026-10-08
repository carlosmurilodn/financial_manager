import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["items", "template"]

  connect() {
    this.refresh()
  }

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", Date.now().toString())
    this.itemsTarget.insertAdjacentHTML("beforeend", content)
    this.refresh()
  }

  remove(event) {
    event.preventDefault()
    const item = event.target.closest("[data-exercise-entry-item]")
    const destroyInput = item.querySelector("[data-destroy-input]")

    if (destroyInput) {
      destroyInput.value = "1"
      item.hidden = true
    } else {
      item.remove()
    }
  }

  changeType() {
    this.refresh()
  }

  refresh() {
    this.element.querySelectorAll("[data-exercise-entry-item]").forEach((item) => {
      const type = item.querySelector("[data-exercise-type]")?.value
      item.querySelectorAll("[data-type-fields]").forEach((section) => {
        section.hidden = section.dataset.typeFields !== type
      })
    })
  }
}
