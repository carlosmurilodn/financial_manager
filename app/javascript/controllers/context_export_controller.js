import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submit", "status", "links", "download"]
  static values = { statusUrl: String }

  connect() {
    this.changed()
    if (this.statusUrlValue) {
      this.signature = this.currentSignature()
      this.busy(true)
      this.poll()
    }
  }

  disconnect() {
    clearTimeout(this.pollTimer)
    this.request?.abort()
  }

  currentSignature() {
    return JSON.stringify(new FormData(this.formTarget).getAll("context_export[groups][]"))
  }

  changed() {
    const selected = this.formTarget.querySelector('input[type="checkbox"]:checked')
    this.submitTarget.disabled = this.pending || !selected
    if (this.signature && this.signature !== this.currentSignature()) {
      this.linksTarget.hidden = true
      this.setStatus("Seleção alterada. Gere um novo ZIP para aplicar as mudanças.")
    }
  }

  async generate(event) {
    event.preventDefault()
    if (this.pending || this.submitTarget.disabled) return
    clearTimeout(this.pollTimer)
    this.request?.abort()
    this.signature = this.currentSignature()
    this.linksTarget.hidden = true
    this.busy(true)
    this.setStatus("Iniciando exportação…")
    try {
      const data = await this.json(this.formTarget.action, { method: "POST", body: new FormData(this.formTarget) })
      this.statusUrlValue = data.status_url
      const url = new URL(window.location.href)
      url.searchParams.set("token", new URL(data.status_url, window.location.origin).searchParams.get("token"))
      window.history.replaceState(window.history.state, "", url)
      this.setStatus(data.message)
      this.poll()
    } catch (error) {
      if (error.name !== "AbortError") {
        this.busy(false)
        this.setStatus(error.message, "danger")
      }
    }
  }

  async json(url, options = {}) {
    this.request = new AbortController()
    const response = await fetch(url, {
      ...options, signal: this.request.signal, credentials: "same-origin", cache: "no-store",
      headers: { Accept: "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "" },
    })
    if (!response.headers.get("Content-Type")?.includes("application/json")) {
      throw new Error("Não foi possível acompanhar a exportação. Confira sua sessão e recarregue a página.")
    }
    const data = await response.json()
    if (!response.ok) throw new Error(data.errors?.join(" ") || data.message || "Não foi possível gerar o ZIP.")
    return data
  }

  async poll() {
    try {
      const data = await this.json(this.statusUrlValue)
      if (data.state === "ready") {
        this.busy(false)
        if (this.signature !== this.currentSignature()) {
          this.setStatus("ZIP concluído com seleção anterior. Gere outro pacote para aplicar as mudanças.")
          return
        }
        this.downloadTarget.href = data.download_url
        this.linksTarget.hidden = false
        this.setStatus(data.message, "success")
      } else if (data.state === "failed") {
        this.busy(false)
        this.setStatus(data.message, "danger")
      } else {
        if (this.signature === this.currentSignature()) this.setStatus(data.message)
        this.pollTimer = setTimeout(() => this.poll(), 2000)
      }
    } catch (error) {
      if (error.name !== "AbortError") {
        this.busy(false)
        this.setStatus(error.message, "danger")
      }
    }
  }

  busy(value) {
    this.pending = value
    this.submitTarget.setAttribute("aria-busy", String(value))
    this.formTarget.setAttribute("aria-busy", String(value))
    this.changed()
  }

  setStatus(message, kind = "info") {
    this.statusTarget.textContent = message
    this.statusTarget.classList.remove("app-alert--info", "app-alert--success", "app-alert--danger")
    this.statusTarget.classList.add(`app-alert--${kind}`)
  }
}
