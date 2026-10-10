import { Controller } from "@hotwired/stimulus"
import { Editor } from "@tiptap/core"
import StarterKit from "@tiptap/starter-kit"
import { LiteraryParagraph, LiteraryHeading, LiteraryEditing } from "../writing/literary_paragraph"

export default class extends Controller {
  static targets = ["host", "content", "title", "lockVersion", "status", "save", "format", "export", "indent"]

  static values = { label: { type: String, default: "capítulo" } }

  connect() {
    this.events = new AbortController()
    this.saving = false
    try {
      const content = JSON.parse(this.contentTarget.value)
      this.editor = new Editor({
        element: this.hostTarget,
        extensions: [
          StarterKit.configure({ paragraph: false, heading: false, code: false, codeBlock: false, link: false, underline: false, trailingNode: false }),
          LiteraryParagraph, LiteraryHeading.configure({ levels: [1, 2] }), LiteraryEditing,
        ],
        content,
        enableContentCheck: true,
        editorProps: {
          attributes: { class: "literary-manuscript", role: "textbox", "aria-multiline": "true", "aria-label": `Texto do ${this.labelValue}`, "aria-describedby": "literary-editor-help", spellcheck: "true", lang: "pt-BR" },
          handleKeyDown: (_view, event) => {
            if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === "s") {
              event.preventDefault()
              this.element.requestSubmit()
              return true
            }
            if (event.key !== "Escape") return false
            this.formatTargets.find(button => !button.disabled)?.focus()
            return true
          },
        },
        onUpdate: () => { this.syncContent(); this.updateDirty() },
        onTransaction: () => this.updateToolbar(),
        onContentError: () => { throw new Error("Conteúdo incompatível com o editor.") },
      })
      this.syncContent()
      this.savedSnapshot = this.element.dataset.savedSnapshot || this.snapshot()
      this.updateDirty()
      this.saveTarget.disabled = false
      this.updateToolbar()
      const options = { signal: this.events.signal }
      window.addEventListener("beforeunload", event => {
        if (!this.dirty && !this.saving) return
        event.preventDefault()
        event.returnValue = ""
      }, options)
      document.addEventListener("turbo:before-visit", event => {
        if ((this.dirty || this.saving) && !window.confirm("Há alterações não salvas. Sair do editor?")) event.preventDefault()
      }, options)
      document.addEventListener("turbo:before-cache", () => {
        this.element.dataset.savedSnapshot = this.savedSnapshot
        this.syncContent()
        this.editor.destroy()
      }, options)
    } catch (error) {
      this.setStatus("Não foi possível abrir o editor. Recarregue a página; o conteúdo salvo foi preservado.", true)
      this.saveTarget.disabled = true
      this.formatTargets.forEach(button => { button.disabled = true })
    }
  }

  disconnect() {
    clearTimeout(this.autosaveTimer)
    this.events?.abort()
    this.editor?.destroy()
  }

  syncContent() {
    if (this.editor && !this.editor.isDestroyed) this.contentTarget.value = JSON.stringify(this.editor.getJSON())
  }

  snapshot() {
    return JSON.stringify({ title: this.titleTarget.value, content: this.contentTarget.value })
  }

  updateDirty() {
    if (!this.editor) return
    this.dirty = this.snapshot() !== this.savedSnapshot
    if (!this.saving && !this.conflicted) this.setStatus(this.dirty ? "Alterações não salvas. Salvamento automático após pausa na escrita." : "Pronto para escrever.")
    this.scheduleAutosave()
  }

  scheduleAutosave() {
    clearTimeout(this.autosaveTimer)
    if (!this.dirty || this.saving || this.conflicted) return
    this.autosaveTimer = setTimeout(() => {
      if (this.dirty && !this.saving && !this.conflicted && this.titleTarget.value.trim()) this.save()
    }, 8000)
  }

  format(event) {
    if (!this.editor) return
    const command = event.currentTarget.dataset.command
    const chain = this.editor.chain().focus()
    switch (command) {
      case "bold": chain.toggleBold().run(); break
      case "italic": chain.toggleItalic().run(); break
      case "strike": chain.toggleStrike().run(); break
      case "paragraph": chain.setParagraph().run(); break
      case "heading1": chain.toggleHeading({ level: 1 }).run(); break
      case "heading2": chain.toggleHeading({ level: 2 }).run(); break
      case "bulletList": chain.toggleBulletList().run(); break
      case "orderedList": chain.toggleOrderedList().run(); break
      case "sceneBreak": chain.setHorizontalRule().run(); break
      case "indent": chain.setFirstLineIndent(true).run(); break
      case "outdent": chain.setFirstLineIndent(false).run(); break
      case "left": chain.setLiteraryAlignment("left").run(); break
      case "justify": chain.setLiteraryAlignment("justify").run(); break
      case "undo": chain.undo().run(); break
      case "redo": chain.redo().run(); break
    }
    this.updateToolbar()
  }

  updateToolbar() {
    if (!this.editor || this.editor.isDestroyed) return
    this.formatTargets.forEach(button => {
      const command = button.dataset.command
      let active = false
      let enabled = true
      switch (command) {
        case "indent": enabled = this.editor.can().setFirstLineIndent(true); active = enabled && this.editor.isActive("paragraph", { firstLineIndent: true }); break
        case "outdent": enabled = this.editor.can().setFirstLineIndent(false); active = enabled && this.editor.isActive("paragraph", { firstLineIndent: false }); break
        case "undo": enabled = this.editor.can().undo(); break
        case "redo": enabled = this.editor.can().redo(); break
        case "heading1": active = this.editor.isActive("heading", { level: 1 }); break
        case "heading2": active = this.editor.isActive("heading", { level: 2 }); break
        case "left": active = this.editor.isActive({ textAlign: "left" }); break
        case "justify": active = this.editor.isActive({ textAlign: "justify" }); break
        default: active = this.editor.isActive(command)
      }
      button.disabled = !enabled
      if (!["undo", "redo", "sceneBreak"].includes(command)) button.setAttribute("aria-pressed", String(active))
    })
  }

  async save(event) {
    event?.preventDefault()
    clearTimeout(this.autosaveTimer)
    if (!this.editor || this.editor.isDestroyed || this.saving || this.conflicted) return
    if (!this.element.reportValidity()) return
    this.syncContent()
    const savedSnapshot = this.snapshot()
    const formData = new FormData(this.element)
    this.saving = true
    this.saveTarget.disabled = true
    this.setStatus(`Salvando ${this.labelValue}…`)
    try {
      const response = await fetch(this.element.action, {
        method: "POST", body: formData, credentials: "same-origin",
        headers: { Accept: "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content },
      })
      if (!response.headers.get("Content-Type")?.includes("application/json")) {
        this.setStatus("Não foi possível salvar. Confira sua sessão e conexão; copie o texto antes de recarregar.", true)
        return
      }
      const result = await response.json()
      if (!response.ok) {
        if (response.status === 409) this.conflicted = true
        throw new Error((result.errors || ["Não foi possível salvar."]).join(" "))
      }
      if (!this.element.isConnected) return
      this.element.action = result.save_url
      let method = this.element.querySelector('input[name="_method"]')
      if (!method) {
        method = document.createElement("input")
        method.type = "hidden"
        method.name = "_method"
        this.element.append(method)
      }
      method.value = "patch"
      this.lockVersionTarget.value = result.lock_version
      this.exportTarget.href = result.export_url
      this.exportTarget.removeAttribute("aria-disabled")
      history.replaceState(history.state, "", result.edit_url)
      this.savedSnapshot = savedSnapshot
      this.element.dataset.savedSnapshot = savedSnapshot
      this.dirty = this.snapshot() !== savedSnapshot
      this.setStatus(this.dirty ? "Texto salvo. Há novas alterações pendentes." : "Texto salvo.")
      this.dispatch("saved", { detail: result })
    } catch (error) {
      const message = error instanceof TypeError ? "Falha de conexão. Seu texto continua no editor; tente salvar novamente." : error.message
      this.setStatus(message || "Falha ao salvar. Seu texto continua no editor; tente novamente.", true)
    } finally {
      this.saving = false
      this.saveTarget.disabled = this.conflicted === true
      if (this.dirty && !this.conflicted && this.snapshot() !== savedSnapshot) this.scheduleAutosave()
    }
  }

  export(event) {
    if (this.exportTarget.getAttribute("aria-disabled") !== "true" && !this.dirty && !this.saving) return
    event.preventDefault()
    this.setStatus(`Salve o ${this.labelValue} antes de exportar.`, true)
    this.saveTarget.focus()
  }

  setStatus(message, error = false) {
    this.statusTarget.textContent = message
    this.statusTarget.classList.toggle("literary-editor-status--error", error)
  }
}
