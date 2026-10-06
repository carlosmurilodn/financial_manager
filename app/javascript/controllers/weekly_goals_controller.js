import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rows", "template"]

  connect() {
    this.nextIndex = 0
  }

  add() {
    const index = `new_${Date.now()}_${this.nextIndex++}`
    this.rowsTarget.insertAdjacentHTML("beforeend", this.templateTarget.innerHTML.replaceAll("NEW_GOAL", index))
    this.rowsTarget.lastElementChild.querySelector("input[type='text']")?.focus()
  }

  remove(event) {
    const row = event.currentTarget.closest("[data-weekly-goal-row]")
    const id = row.querySelector("input[name$='[id]']")?.value
    if (!id) {
      row.remove()
      return
    }

    row.querySelector("[data-weekly-goal-destroy]").value = "1"
    row.querySelectorAll("input:not([type='hidden'])").forEach((input) => {
      input.disabled = true
    })
    row.hidden = true
  }
}
