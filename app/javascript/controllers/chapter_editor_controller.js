import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["titleForm", "title", "lockVersion", "save", "status", "format", "scenes", "template"]

  connect() {
    this.savedTitle = this.titleTarget.value
    this.events = new AbortController()
    const options = { signal: this.events.signal }
    const nav = document.querySelector(".app-sidebar__nav")
    const updateOffset = () => {
      const height = window.matchMedia("(max-width: 991px)").matches ? nav?.getBoundingClientRect().height || 0 : 0
      this.element.style.setProperty("--writing-sticky-top", `${Math.ceil(height) + 8}px`)
    }
    this.navObserver = new ResizeObserver(updateOffset)
    if (nav) this.navObserver.observe(nav)
    window.addEventListener("resize", updateOffset, options)
    updateOffset()
    this.element.addEventListener("literary-editor:toolbar", event => {
      if (event.detail.controller === this.activeScene) this.refreshToolbar()
    }, options)
    this.element.addEventListener("keydown", event => {
      if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === "s") {
        event.preventDefault()
        event.stopPropagation()
        this.save()
      }
    }, { ...options, capture: true })
    window.addEventListener("beforeunload", event => {
      if (!this.pending) return
      event.preventDefault()
      event.returnValue = ""
    }, options)
    document.addEventListener("turbo:before-visit", event => {
      if (this.pending && !window.confirm("Há alterações não salvas. Sair do editor?")) event.preventDefault()
    }, options)
    requestAnimationFrame(() => {
      if (this.element.isConnected && !this.activeScene) this.setActive(this.editors[0])
      this.summary()
    })
  }

  disconnect() {
    this.navObserver?.disconnect()
    this.events.abort()
    clearTimeout(this.titleTimer)
  }

  get editors() {
    return Array.from(this.scenesTarget.querySelectorAll(".chapter-scene-editor"))
      .map(form => this.application.getControllerForElementAndIdentifier(form, "literary-editor")).filter(Boolean)
  }

  get pending() {
    return this.titleTarget.value !== this.savedTitle || this.savingTitle || this.editors.some(scene => scene.dirty || scene.saving)
  }

  get panel() {
    return this.application.getControllerForElementAndIdentifier(this.element, "narrative-panel")
  }

  activate(event) { this.setActive(event.detail.controller) }

  setActive(scene) {
    if (!scene || this.activeScene === scene) return
    this.activeScene = scene
    this.editors.forEach(editor => editor.element.classList.toggle("is-active", editor === scene))
    this.panel?.documentSaved({ detail: { context_url: scene.element.dataset.contextUrl || "" } })
    if (this.panel && !scene.element.dataset.contextUrl) {
      this.panel.urlValue = ""
      this.panel.selection = null
      if (this.panel.open) this.panel.load()
    }
    this.refreshToolbar()
  }

  refreshToolbar() { this.activeScene?.updateToolbar(this.formatTargets) }
  format(event) { this.activeScene?.format(event); this.refreshToolbar() }
  sceneStatus() { this.summary() }

  sceneSaved(event) {
    if (event.target === this.activeScene?.element) this.panel?.documentSaved(event)
    this.summary()
  }

  summary() {
    if (!this.hasStatusTarget) return
    const failed = this.titleError || this.editors.some(scene => scene.error || scene.conflicted)
    this.statusTarget.textContent = failed ? "Há alterações que não puderam ser salvas. Confira os avisos nas cenas." : this.pending ? "Alterações pendentes · salvamento automático após pausa." : "Todas as alterações salvas."
    this.statusTarget.classList.toggle("literary-editor-status--error", !!failed)
  }

  titleChanged() {
    clearTimeout(this.titleTimer)
    this.summary()
    this.titleTimer = setTimeout(() => this.saveTitle(), 6000)
  }

  async saveTitle() {
    clearTimeout(this.titleTimer)
    if (this.savingTitle || this.titleConflicted || this.titleTarget.value === this.savedTitle) return
    if (!this.titleFormTarget.reportValidity()) return
    const title = this.titleTarget.value
    this.savingTitle = true
    this.titleError = false
    try {
      const response = await fetch(this.titleFormTarget.action, {
        method: "POST", body: new FormData(this.titleFormTarget), credentials: "same-origin",
        headers: { Accept: "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content },
      })
      if (!response.headers.get("Content-Type")?.includes("application/json")) throw new Error("Confira sua sessão e conexão.")
      const result = await response.json()
      if (!response.ok) {
        if (response.status === 409) this.titleConflicted = true
        throw new Error((result.errors || ["Não foi possível salvar o título."]).join(" "))
      }
      if (!this.element.isConnected) return
      this.lockVersionTarget.value = result.lock_version
      this.savedTitle = title
    } catch (error) {
      this.titleError = true
      this.statusTarget.textContent = error.message
      this.statusTarget.classList.add("literary-editor-status--error")
    } finally {
      this.savingTitle = false
      if (!this.titleError) this.summary()
      if (!this.titleError && this.titleTarget.value !== this.savedTitle) this.titleChanged()
    }
  }

  async save(event) {
    event?.preventDefault()
    if (this.savingAll) return
    this.savingAll = true
    this.saveTarget.disabled = true
    try {
      await this.saveTitle()
      for (const scene of this.editors) if (scene.dirty) await scene.save()
    } finally {
      this.savingAll = false
      this.saveTarget.disabled = false
      this.summary()
    }
  }

  async export(event) {
    event.preventDefault()
    const url = event.currentTarget.href
    await this.save()
    if (this.pending || this.titleError || this.editors.some(scene => scene.error || scene.conflicted)) {
      this.statusTarget.textContent = "Salve todas as alterações antes de exportar."
      this.statusTarget.classList.add("literary-editor-status--error")
      return
    }
    window.location.assign(url)
  }

  addScene() {
    const number = this.scenesTarget.querySelectorAll(".chapter-scene-editor").length + 1
    const token = `new_scene_${Date.now()}_${number}`
    const template = document.createElement("template")
    template.innerHTML = this.templateTarget.innerHTML.replaceAll("NEW_NUMBER", String(number)).replaceAll("NEW_TOKEN", token)
    const form = template.content.querySelector("form")
    this.scenesTarget.append(template.content)
    requestAnimationFrame(() => {
      this.setActive(this.application.getControllerForElementAndIdentifier(form, "literary-editor"))
      form.querySelector('input[type="text"]')?.focus()
      form.scrollIntoView({ behavior: window.matchMedia("(prefers-reduced-motion: reduce)").matches ? "auto" : "smooth", block: "start" })
    })
  }
}
