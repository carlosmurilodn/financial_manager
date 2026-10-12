import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "status"]

  disconnect() {
    this.dialogTarget.close()
  }

  open(event) {
    this.opener = event.currentTarget
    this.dialogTarget.showModal()
  }

  close(event) {
    event?.preventDefault()
    if (this.saving) return
    this.dialogTarget.close()
    this.opener?.focus()
  }

  closeOutside(event) {
    if (event.target !== event.currentTarget) return
    const bounds = event.currentTarget.getBoundingClientRect()
    if (event.clientX < bounds.left || event.clientX > bounds.right || event.clientY < bounds.top || event.clientY > bounds.bottom) this.close(event)
  }

  async copy(event) {
    event.preventDefault()
    if (this.saving) return
    const form = event.currentTarget
    const dates = this.operation?.dates || new FormData(form).getAll("dates[]")
    if (!dates.length) {
      this.statusTarget.textContent = "Selecione ao menos um dia de destino."
      return
    }
    this.operation ||= { dates, token: crypto.randomUUID() }
    this.saving = true
    this.lockForm(form, true)
    this.statusTarget.textContent = "Copiando refeição…"
    let confirmed = false
    try {
      const response = await fetch(form.action, {
        method: "POST",
        headers: { Accept: "application/json", "Content-Type": "application/json", "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content },
        body: JSON.stringify({ dates: this.operation.dates, request_token: this.operation.token })
      })
      const data = await response.json()
      confirmed = response.ok || response.status === 422
      if (!response.ok) throw new Error(data.error || "Não foi possível copiar.")
      data.days.forEach(day => {
        const panel = document.getElementById(`nutrition-panel-${day.date}`)
        panel?.dispatchEvent(new CustomEvent("nutrition-meals:changed", { detail: { ...day, message: data.message } }))
      })
      const notice = this.element.querySelector("[data-meal-picker-target='managementStatus']")
      notice.textContent = data.message
      notice.classList.remove("is-error")
      this.operation = null
      this.statusTarget.textContent = data.message
      form.reset()
      this.dialogTarget.close()
      this.opener?.focus()
    } catch (error) {
      if (confirmed) this.operation = null
      this.statusTarget.textContent = confirmed ? error.message : "Resposta não confirmada. Tente novamente para confirmar a mesma cópia sem duplicar."
    } finally {
      this.saving = false
      this.lockForm(form, false)
    }
  }

  lockForm(form, saving) {
    form.querySelectorAll("button").forEach(button => { button.disabled = saving })
    form.querySelectorAll("input[type='checkbox']").forEach(input => { input.disabled = saving || Boolean(this.operation) })
  }
}
