import { Controller } from "@hotwired/stimulus"
import { Selection } from "@tiptap/pm/state"

export default class extends Controller {
  static targets = ["panel", "toggle", "kind", "query", "all", "results", "status"]
  static values = { url: String }

  connect() {
    this.open = false
    this.events = new AbortController()
    this.element.addEventListener("pointerdown", event => {
      if (this.panelTarget.contains(event.target) || this.toggleTargets.some(button => button.contains(event.target))) this.captureSelection()
    }, { signal: this.events.signal })
    this.panelTarget.addEventListener("keydown", event => {
      if (event.key === "Escape") { event.preventDefault(); this.close(); this.returnToWriting() }
    }, { signal: this.events.signal })
  }

  disconnect() {
    this.events.abort()
    this.request?.abort()
    this.mutation?.abort()
    clearTimeout(this.searchTimer)
  }

  get editorController() {
    const chapter = this.application.getControllerForElementAndIdentifier(this.element, "chapter-editor")
    if (chapter) return chapter.activeScene
    const form = this.element.querySelector(".literary-editor")
    return form ? this.application.getControllerForElementAndIdentifier(form, "literary-editor") : null
  }

  captureSelection() {
    const editor = this.editorController?.editor
    if (editor && !editor.isDestroyed) this.selection = editor.state.selection.toJSON()
  }

  returnToWriting() {
    const editor = this.editorController?.editor
    if (!editor || editor.isDestroyed) { this.toggleTargets[0]?.focus(); return }
    try {
      if (this.selection) editor.view.dispatch(editor.state.tr.setSelection(Selection.fromJSON(editor.state.doc, this.selection)))
    } catch { /* Selection may no longer exist after edits; keep current selection. */ }
    editor.commands.focus()
  }

  toggle() {
    this.open ? this.close() : this.show()
  }

  show() {
    this.captureSelection()
    this.open = true
    this.panelTarget.hidden = false
    this.element.classList.add("narrative-panel-open")
    this.toggleTargets.forEach(button => button.setAttribute("aria-expanded", "true"))
    this.load()
    this.kindTarget.focus()
  }

  close() {
    this.open = false
    this.panelTarget.hidden = true
    this.element.classList.remove("narrative-panel-open")
    this.toggleTargets.forEach(button => button.setAttribute("aria-expanded", "false"))
    this.toggleTargets[0]?.focus()
  }

  documentSaved(event) {
    if (!event.detail.context_url) return
    const changed = this.urlValue !== event.detail.context_url
    this.urlValue = event.detail.context_url
    if (changed) this.selection = null
    if (changed && this.open) this.load()
  }

  search() {
    clearTimeout(this.searchTimer)
    this.request?.abort()
    this.resultsTarget.replaceChildren()
    this.setStatus("Pesquisando…")
    this.searchTimer = setTimeout(() => this.load(), 300)
  }

  contextURL() {
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("kind", this.kindTarget.value)
    return url
  }

  async requestJSON(url, options = {}) {
    const response = await fetch(url, {
      credentials: "same-origin", ...options,
      headers: { Accept: "application/json", "Content-Type": "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "", ...options.headers },
    })
    if (!response.headers.get("Content-Type")?.includes("application/json")) throw new Error("Confira sua sessão e conexão. Texto permanece no editor.")
    const data = await response.json()
    if (!response.ok) throw new Error((data.errors || ["Não foi possível consultar o painel."]).join(" "))
    return data
  }

  async load() {
    clearTimeout(this.searchTimer)
    this.request?.abort()
    this.resultsTarget.replaceChildren()
    if (!this.urlValue) { this.setStatus("Salve o capítulo ou cena primeiro para associar elementos."); return }
    this.request = new AbortController()
    this.setStatus("Carregando…")
    const url = this.contextURL()
    url.searchParams.set("query", this.queryTarget.value)
    url.searchParams.set("all", this.allTarget.checked ? "1" : "0")
    try {
      const data = await this.requestJSON(url, { signal: this.request.signal })
      this.setStatus(data.more ? "Mostrando 50 registros. Refine a pesquisa para encontrar outros." : "")
      if (!data.records.length) {
        this.resultsTarget.append(this.text("p", "Nenhum registro encontrado. Pesquise no livro ou marque a opção de mostrar todos.", "writing-muted"))
      }
      data.records.forEach(record => this.renderRecord(record))
    } catch (error) {
      if (error.name !== "AbortError") this.setStatus(error.message, true)
    }
  }

  renderRecord(record) {
    const card = this.text("article", "", "literary-narrative-record")
    const title = this.text("button", record.name, "literary-narrative-record__name")
    title.type = "button"
    title.addEventListener("click", () => this.details(record.id))
    card.append(title, this.text("p", record.summary || "Detalhes disponíveis na ficha", "writing-muted"))
    const button = this.actionButton(record.associated ? "link_off" : "add_link", record.associated ? "Remover associação" : "Associar")
    button.addEventListener("click", () => this.changeAssociation(record, button))
    card.append(button)
    this.resultsTarget.append(card)
  }

  async details(id) {
    this.request?.abort()
    this.request = new AbortController()
    const url = this.contextURL()
    url.searchParams.set("record_id", id)
    this.setStatus("Abrindo ficha…")
    try {
      const { record } = await this.requestJSON(url, { signal: this.request.signal })
      const back = this.actionButton("arrow_back", "Voltar à lista")
      back.addEventListener("click", () => this.load())
      const heading = this.text("h3", record.name)
      heading.tabIndex = -1
      const details = document.createElement("dl")
      details.className = "literary-narrative-details"
      record.details.forEach(field => {
        const row = document.createElement("div")
        row.append(this.text("dt", field.label), this.text("dd", field.value))
        details.append(row)
      })
      if (!record.details.length) details.append(this.text("p", "Ficha ainda não preenchida.", "writing-muted"))
      this.resultsTarget.replaceChildren(back, heading, this.text("p", record.summary, "writing-muted"), details)
      this.setStatus("")
      heading.focus()
    } catch (error) {
      if (error.name !== "AbortError") this.setStatus(error.message, true)
    }
  }

  async changeAssociation(record, button) {
    if (this.changing) return
    this.changing = true
    button.disabled = true
    this.mutation = new AbortController()
    const url = this.contextURL()
    try {
      const data = await this.requestJSON(url, { method: record.associated ? "DELETE" : "POST", body: JSON.stringify({ record_id: record.id }), signal: this.mutation.signal })
      document.dispatchEvent(new CustomEvent("writing:saved"))
      // Load the currently selected section, even if it changed during the mutation.
      await this.load()
      this.setStatus(data.message)
    } catch (error) {
      if (error.name !== "AbortError") this.setStatus(error.message, true)
    } finally {
      this.changing = false
      button.disabled = false
    }
  }

  text(tag, content, className = "") {
    const element = document.createElement(tag)
    element.textContent = content
    element.className = className
    return element
  }

  actionButton(icon, label) {
    const button = this.text("button", "", "app-btn app-btn--secondary")
    button.type = "button"
    const symbol = this.text("span", icon, "material-symbols-rounded")
    symbol.setAttribute("aria-hidden", "true")
    button.append(symbol, this.text("span", label))
    return button
  }

  setStatus(message, error = false) {
    this.statusTarget.textContent = message
    this.statusTarget.classList.toggle("app-alert", error)
    this.statusTarget.classList.toggle("app-alert--danger", error)
  }
}
