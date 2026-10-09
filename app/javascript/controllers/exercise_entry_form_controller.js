import { Controller } from "@hotwired/stimulus"
import $ from "jquery"

export default class extends Controller {
  static targets = ["items", "template"]

  connect() {
    this.exerciseOptions = new WeakMap()
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
    this.refresh()
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

  changeMuscleGroup(event) {
    this.filterExercises(event.target.closest("[data-strength-log]"))
  }

  filterExercises(log) {
    const group = log.querySelector("[data-muscle-group]")
    const exercises = log.querySelector("[data-strength-exercise]")
    if (!group || !exercises) return

    if (!this.exerciseOptions.has(exercises)) {
      this.exerciseOptions.set(exercises, Array.from(exercises.options, (option) => option.cloneNode(true)))
    }

    const selected = exercises.value
    const options = this.exerciseOptions.get(exercises).filter((option) => {
      return option.value === "" || option.dataset.muscleGroupId === group.value
    })
    exercises.replaceChildren(...options.map((option) => option.cloneNode(true)))
    exercises.value = options.some((option) => option.value === selected) ? selected : ""
    $(exercises).trigger("change.select2")
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
    this.element.querySelectorAll("[data-strength-log]").forEach((log) => this.filterExercises(log))
  }
}
