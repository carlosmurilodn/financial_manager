import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "scope", "chapters", "submit", "summary", "fontNote", "status", "links", "download", "open", "preview"]
  static values = { fonts: Object, statusUrl: String }

  connect() {
    this.originalDisabled = this.submitTarget.disabled
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

  formValues() {
    return Object.fromEntries(new FormData(this.formTarget))
  }

  currentSignature() {
    return JSON.stringify([...new FormData(this.formTarget).entries()])
  }

  changed() {
    const selected = this.scopeTargets.find(input => input.checked)?.value === "selected"
    this.chaptersTarget.hidden = !selected
    this.chaptersTarget.querySelectorAll('input[type="checkbox"]').forEach(input => { input.disabled = !selected })
    const values = this.formValues()
    const font = values["publication[font]"]
    const family = this.fontsValue[font] || font
    this.fontNoteTarget.textContent = family === font ? `Fonte incorporada ao PDF: ${family}.` : `${font} indisponível neste servidor. PDF usará ${family}, com acentuação preservada.`
    const count = new FormData(this.formTarget).getAll("publication[chapter_ids][]").filter(Boolean).length
    const format = values["publication[page_format]"] === "editorial" ? "16 × 23 cm" : values["publication[page_format]"]?.toUpperCase()
    const options = [format, family, `${values["publication[font_size]"]} pt`, `Entrelinha ${values["publication[line_height]"]?.replace(".", ",")}`, selected ? `${count} capítulo(s)` : "Livro completo"]
    if (values["publication[include_cover]"] === "1") options.push("Com capa")
    if (values["publication[include_title_page]"] === "1") options.push("Com folha de rosto")
    if (values["publication[include_toc]"] === "1") options.push("Com sumário")
    if (values["publication[paginate]"] === "1") options.push("Com paginação")
    this.summaryTarget.textContent = options.join(" · ")
    if (this.signature && this.currentSignature() !== this.signature) {
      this.linksTarget.hidden = true
      this.previewTarget.hidden = true
      this.previewTarget.removeAttribute("src")
      this.setStatus("Configurações alteradas. Gere uma nova prévia para aplicar as mudanças.")
    }
  }

  async generate(event) {
    event.preventDefault()
    if (this.pending || this.originalDisabled) return
    clearTimeout(this.pollTimer)
    this.request?.abort()
    this.signature = this.currentSignature()
    this.linksTarget.hidden = true
    this.previewTarget.hidden = true
    this.previewTarget.removeAttribute("src")
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
      if (error.name !== "AbortError") { this.busy(false); this.setStatus(error.message, "danger") }
    }
  }

  async json(url, options = {}) {
    this.request = new AbortController()
    const response = await fetch(url, {
      ...options, signal: this.request.signal, credentials: "same-origin", cache: "no-store",
      headers: { Accept: "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "" },
    })
    if (!response.headers.get("Content-Type")?.includes("application/json")) throw new Error("Não foi possível acompanhar a exportação. Confira sua sessão e recarregue a página.")
    const data = await response.json()
    if (!response.ok) throw new Error(data.errors?.join(" ") || data.message || "Não foi possível gerar o PDF.")
    return data
  }

  async poll() {
    try {
      const data = await this.json(this.statusUrlValue)
      if (data.state === "ready") {
        this.busy(false)
        if (this.currentSignature() !== this.signature) {
          this.setStatus("PDF concluído com configurações anteriores. Gere uma nova prévia para aplicar as mudanças.")
          return
        }
        this.downloadTarget.href = data.download_url
        this.openTarget.href = data.preview_url
        this.linksTarget.hidden = false
        this.previewTarget.src = data.preview_url
        this.previewTarget.hidden = false
        this.setStatus(`${data.message} Fonte: ${data.font_family}.`, "success")
      } else if (data.state === "failed") {
        this.busy(false)
        this.setStatus(data.message, "danger")
      } else {
        if (this.currentSignature() === this.signature) this.setStatus(data.message)
        this.pollTimer = setTimeout(() => this.poll(), 2000)
      }
    } catch (error) {
      if (error.name !== "AbortError") { this.busy(false); this.setStatus(error.message, "danger") }
    }
  }

  busy(value) {
    this.pending = value
    this.submitTarget.disabled = value || this.originalDisabled
    this.submitTarget.setAttribute("aria-busy", String(value))
    this.formTarget.setAttribute("aria-busy", String(value))
  }

  setStatus(message, kind = "info") {
    this.statusTarget.textContent = message
    this.statusTarget.classList.remove("app-alert--info", "app-alert--success", "app-alert--danger")
    this.statusTarget.classList.add(`app-alert--${kind}`)
  }
}
