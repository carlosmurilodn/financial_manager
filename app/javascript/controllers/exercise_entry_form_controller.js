import { Controller } from "@hotwired/stimulus"
import { initSelect2 } from "../select2_init"

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
    initSelect2(logs)
    this.filterStrengthExercises()
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

  filterStrengthExercises(event) {
    const logs = event ? [event.target.closest("[data-strength-log]")] : this.element.querySelectorAll("[data-strength-log]")

    logs.forEach((log) => {
      if (!log) return

      const muscleGroupId = log.querySelector("[data-strength-muscle-group]")?.value
      const exerciseSelect = log.querySelector("[data-strength-exercise]")

      if (!exerciseSelect) return

      Array.from(exerciseSelect.options).forEach((option) => {
        const optionMuscleGroupId = option.dataset.muscleGroupId
        const visible = option.value === "" || !muscleGroupId || optionMuscleGroupId === muscleGroupId
        option.hidden = !visible
        option.disabled = !visible
      })

      if (exerciseSelect.selectedOptions[0]?.disabled) {
        exerciseSelect.value = ""
        exerciseSelect.dispatchEvent(new Event("change", { bubbles: true }))
      }
    })
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
    this.filterStrengthExercises()
  }
}
