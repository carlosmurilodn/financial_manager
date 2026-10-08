import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { formId: String }

  toggle(event) {
    const form = document.getElementById(this.formIdValue)
    const status = form?.querySelector('[name="exercise_day[exercise_status]"]')
    if (!status) return
    event.preventDefault()
    if (!form.reportValidity()) return
    status.value = status.value === "completed" ? "not_completed" : "completed"
    const button = this.element.querySelector("button")
    button.classList.remove("exercise-calendar-day--unselected", "exercise-calendar-day--completed", "exercise-calendar-day--not_completed")
    button.classList.add(`exercise-calendar-day--${status.value}`)
    button.setAttribute("aria-pressed", String(status.value === "completed"))
    form.requestSubmit()
  }
}
