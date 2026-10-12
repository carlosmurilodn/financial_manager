import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["meals", "empty", "status"]

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
      this.emptyTarget.hidden = true
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
