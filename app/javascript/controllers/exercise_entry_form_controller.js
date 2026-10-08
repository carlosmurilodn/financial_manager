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

  addStrengthLog(event) {
    event.preventDefault()
    const item = event.target.closest("[data-exercise-entry-item]")
    const template = item.querySelector("[data-strength-template]")
    const logs = item.querySelector("[data-strength-logs]")
    const content = template.innerHTML.replaceAll("NEW_STRENGTH_RECORD", Date.now().toString())
    logs.insertAdjacentHTML("beforeend", content)
  }

  removeStrengthLog(event) {
    event.preventDefault()
    const log = event.target.closest("[data-strength-log]")
    const destroyInput = log.querySelector("[data-strength-destroy-input]")

    if (destroyInput) {
      destroyInput.value = "1"
      log.hidden = true
    } else {
      log.remove()
    }
  }

  changeType() {
    this.refresh()
  }

  refresh() {
    this.element.querySelectorAll("[data-exercise-entry-item]").forEach((item) => {
      const type = item.querySelector("[data-exercise-type]")?.value
      item.querySelectorAll("[data-type-fields]").forEach((section) => {
        const visible = section.dataset.typeFields === type
        section.hidden = !visible
        section.querySelectorAll("input, select, textarea, button").forEach((field) => {
          field.disabled = !visible
        })
      })
    })
  }
}
