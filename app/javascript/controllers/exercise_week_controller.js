import { Controller } from "@hotwired/stimulus"
import { renderStreamMessage } from "@hotwired/turbo"

export default class extends Controller {
  connect() {
    this.queue = []
    this.processing = false
  }

  save(event) {
    if (event.defaultPrevented) return
    event.preventDefault()
    const form = event.target
    if (!form.reportValidity()) return
    const prefix = form.id.replace(/-form$/, "")
    if (this.queue.some(request => request.prefix === prefix) || this.activePrefix === prefix) return
    this.queue.push({ url: form.action, body: new FormData(form), prefix })
    this.setBusy(prefix, true)
    this.processQueue()
  }

  async processQueue() {
    if (this.processing) return
    this.processing = true
    while (this.queue.length) {
      const request = this.queue.shift()
      this.activePrefix = request.prefix
      try {
        const response = await fetch(request.url, {
          method: "POST",
          body: request.body,
          credentials: "same-origin",
          headers: { Accept: "text/vnd.turbo-stream.html", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "" }
        })
        if (!response.headers.get("Content-Type")?.includes("text/vnd.turbo-stream.html")) throw new Error("Unexpected response")
        renderStreamMessage(await response.text())
      } catch {
        this.showError(request.prefix)
      } finally {
        this.setBusy(request.prefix, false)
        this.activePrefix = null
      }
    }
    this.processing = false
  }

  setBusy(prefix, busy) {
    const calendar = document.getElementById(`${prefix}-calendar`)
    const form = document.getElementById(`${prefix}-form`)
    if (calendar) calendar.disabled = busy
    form?.querySelectorAll('button[type="submit"], input[type="submit"]').forEach(button => { button.disabled = busy })
    document.getElementById(prefix)?.setAttribute("aria-busy", String(busy))
  }

  showError(prefix) {
    const card = document.getElementById(prefix)
    const message = card?.querySelector(".exercise-day-card__saved")
    if (message) {
      message.textContent = "Não foi possível salvar. Tente novamente."
      message.setAttribute("role", "alert")
    }
  }
}
