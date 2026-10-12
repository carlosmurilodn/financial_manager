import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["meals", "empty", "status", "daySummary"]

  refresh(event) {
    const data = event.detail
    if (data.meals_html !== undefined) this.mealsTarget.innerHTML = data.meals_html
    this.daySummaryTarget.innerHTML = data.day_html
    const tab = document.getElementById(this.element.getAttribute("aria-labelledby"))
    const calories = tab?.querySelector(".nutrition-week__tab-calories")
    if (calories && data.tab_calories) calories.textContent = data.tab_calories
    this.emptyTarget.hidden = data.has_meals
    this.statusTarget.textContent = data.message
  }

  async create(event) {
    event.preventDefault()
    if (this.saving) return
    const form = event.currentTarget
    if (!form.reportValidity()) return
    this.saving = true
    const button = form.querySelector("button[type='submit']")
    button.disabled = true
    this.statusTarget.textContent = "Salvando refeição…"

    try {
      const response = await fetch(form.action, {
        method: "POST", body: new FormData(form),
        headers: { Accept: "application/json", "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content }
      })
      const data = await response.json()
      if (!response.ok) throw new Error(data.error || "Não foi possível salvar a refeição.")
      this.mealsTarget.insertAdjacentHTML("beforeend", data.html)
      this.refresh({ detail: data })
      form.reset()
      this.statusTarget.textContent = data.message
    } catch (error) {
      this.statusTarget.textContent = error.message === "Failed to fetch" ? "Falha de conexão. Nome e data foram preservados." : error.message
    } finally {
      this.saving = false
      button.disabled = false
    }
  }
}
