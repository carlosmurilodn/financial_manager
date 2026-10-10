import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submit", "message", "result", "attempt", "success", "counts", "obsolete", "obsoleteSection"]
  static values = { bookId: Number }

  connect() {
    this.originalDisabled = this.submitTarget.disabled
  }

  async synchronize(event) {
    event.preventDefault()
    if (this.pending || this.originalDisabled) return
    this.busy(true)
    this.setMessage("Sincronizando documentos salvos com GitHub… Aguarde a conclusão.")
    try {
      const response = await fetch(this.formTarget.action, {
        method: "POST", body: new FormData(this.formTarget), credentials: "same-origin", cache: "no-store",
        headers: { Accept: "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "" },
      })
      if (!response.headers.get("Content-Type")?.includes("application/json")) {
        throw new Error("Não foi possível acompanhar a tentativa. Recarregue a página para consultar o resultado.")
      }
      const data = await response.json()
      this.renderResult(data)
      this.setMessage(data.message || "Não foi possível concluir a sincronização.", response.ok && data.success ? "success" : "danger")
    } catch (error) {
      this.setMessage(error.message || "Falha de comunicação. Recarregue a página para consultar o resultado.", "danger")
    } finally {
      this.busy(false)
      this.dispatch("finished")
    }
  }

  publicationFinished(event) {
    if (event.detail.bookId !== this.bookIdValue) return
    this.renderResult(event.detail)
    this.setMessage(event.detail.message, event.detail.success ? "success" : "danger")
  }

  renderResult(data) {
    if (!data.status_label) return
    this.resultTarget.textContent = data.status_label
    this.attemptTarget.textContent = data.last_attempt
    this.successTarget.textContent = data.last_success
    this.countsTarget.textContent = `${data.created_count} criados · ${data.updated_count} atualizados · ${data.unchanged_count} sem alterações`
    this.obsoleteTarget.replaceChildren(...data.obsolete_files.map(path => {
      const item = document.createElement("li")
      item.textContent = path
      return item
    }))
    this.obsoleteSectionTarget.hidden = data.obsolete_files.length === 0
  }

  busy(value) {
    this.pending = value
    this.submitTarget.disabled = value || this.originalDisabled
    this.submitTarget.setAttribute("aria-busy", String(value))
    this.formTarget.setAttribute("aria-busy", String(value))
  }

  setMessage(message, kind = "info") {
    this.messageTarget.textContent = message
    this.messageTarget.classList.remove("app-alert--info", "app-alert--success", "app-alert--danger")
    this.messageTarget.classList.add(`app-alert--${kind}`)
  }
}
