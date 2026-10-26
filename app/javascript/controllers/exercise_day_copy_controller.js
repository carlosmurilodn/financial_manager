import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dates", "template"]

  add() {
    const template = document.createElement("template")
    template.innerHTML = this.templateTarget.innerHTML.replaceAll("NEW_DATE", `copy-date-${crypto.randomUUID()}`)
    const row = template.content.firstElementChild
    this.datesTarget.append(row)
    row.querySelector("input").focus()
  }

  remove(event) {
    const row = event.currentTarget.closest("[data-date-row]")
    if (this.datesTarget.children.length === 1) {
      const input = row.querySelector("input")
      input.value = ""
      input.focus()
    } else {
      row.remove()
      this.datesTarget.querySelector("input").focus()
    }
  }
}
