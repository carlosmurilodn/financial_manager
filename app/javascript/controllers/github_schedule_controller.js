import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["states", "message", "submit"]
  static values = { url: String }

  connect() {
    this.connected = true
    this.states = []
    this.configured = false
    try {
      this.channel = new BroadcastChannel("writing-github-changes")
      this.channel.onmessage = () => this.refresh()
    } catch { /* Tab focus and saved events still work without BroadcastChannel. */ }
    this.refresh()
  }

  disconnect() {
    this.connected = false
    clearTimeout(this.timer)
    this.channel?.close()
    this.request?.abort()
  }

  changed() {
    this.channel?.postMessage("changed")
    this.refresh()
  }

  returned() {
    this.refresh()
  }

  async json(url, options = {}) {
    const response = await fetch(url, {
      credentials: "same-origin", cache: "no-store", signal: this.request.signal, ...options,
      headers: { Accept: "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "", ...options.headers },
    })
    if (!response.headers.get("Content-Type")?.includes("application/json")) {
      throw new Error("Confira sua sessão e conexão para acompanhar a sincronização.")
    }
    const data = await response.json()
    if (!response.ok && response.status !== 409 && response.status !== 422) {
      throw new Error(data.message || "Não foi possível consultar a sincronização.")
    }
    return { response, data }
  }

  async refresh() {
    if (!this.connected) return
    if (this.requesting) { this.refreshAfter = true; return }
    clearTimeout(this.timer)
    this.requesting = true
    this.request = new AbortController()
    let failed = false
    try {
      const { data } = await this.json(this.urlValue)
      this.configured = data.configured
      this.states = data.states
      this.renderStates()
      const due = this.configured && this.states.find(state => state.due)
      if (due) {
        this.updateSummary({ ...due, processing: true })
        this.messageTarget.textContent = `Sincronizando ${due.title} com GitHub…`
        const url = new URL(due.sync_url, window.location.origin)
        url.searchParams.set("mode", "automatic")
        const result = await this.json(url, { method: "POST" })
        this.messageTarget.textContent = result.data.message || "Tentativa concluída."
        this.dispatch("published", { detail: { bookId: due.book_id, ...result.data } })
        this.channel?.postMessage("changed")
        const updated = await this.json(this.urlValue)
        this.states = updated.data.states
        this.renderStates()
      } else {
        this.messageTarget.textContent = this.configured ? "" : "Integração GitHub não configurada no servidor. Pendências permanecem salvas."
      }
    } catch (error) {
      if (error.name !== "AbortError" && this.connected) {
        failed = true
        this.messageTarget.textContent = error.message || "Falha de conexão. Pendências permanecem salvas."
      }
    } finally {
      this.requesting = false
      if (this.connected) {
        if (this.refreshAfter) {
          this.refreshAfter = false
          this.timer = setTimeout(() => this.refresh(), 1000)
        } else if (failed || (this.configured && this.states.some(state => state.poll))) {
          this.timer = setTimeout(() => this.refresh(), failed ? 60000 : 30000)
        }
      }
    }
  }

  renderStates() {
    if (!this.connected) return
    this.states.forEach(state => this.updateSummary(state))
    const rows = this.states.map(state => {
      const row = document.createElement("p")
      const heading = document.createElement("strong")
      heading.textContent = `${state.title}: ${state.status_label}`
      row.append(heading)
      if (state.pending && state.scheduled_display) row.append(document.createTextNode(` · Próximo envio: ${state.scheduled_display}`))
      if (state.last_success) row.append(document.createTextNode(` · Última sincronização: ${state.last_success}`))
      if (state.error_message) row.append(document.createTextNode(` · ${state.error_message}`))
      const details = document.createElement("a")
      details.href = state.sync_url
      details.textContent = "Detalhes e envio manual"
      row.append(document.createTextNode(" · "), details)
      return row
    })
    if (!rows.length) {
      const empty = document.createElement("p")
      empty.textContent = "Nenhuma sincronização pendente."
      rows.push(empty)
    }
    this.statesTarget.replaceChildren(...rows)
    this.submitTargets.forEach(button => { button.disabled = !this.configured })
  }

  updateSummary(state) {
    let kind = "neutral"
    let label = "Nunca sincronizado"
    if (!this.configured) {
      label = "Não configurado"
    } else if (state.processing) {
      kind = "info"; label = "Sincronizando"
    } else if (state.error_message) {
      kind = "danger"; label = "Falha"
    } else if (state.pending) {
      kind = "warning"; label = "Pendente"
      if (state.scheduled_at) label += ` · ${new Intl.DateTimeFormat("pt-BR", { hour: "2-digit", minute: "2-digit", timeZone: "America/Sao_Paulo" }).format(new Date(state.scheduled_at))}`
    } else if (state.last_success) {
      kind = "success"; label = "Sincronizado"
    }
    document.querySelectorAll("[data-github-sync-summary-book-id]").forEach(pill => {
      if (Number(pill.dataset.githubSyncSummaryBookId) !== state.book_id) return
      pill.textContent = label
      pill.dataset.kind = kind
      pill.title = state.error_message || (state.pending && state.scheduled_display ? `Próximo envio: ${state.scheduled_display}` : state.last_success ? `Última sincronização: ${state.last_success}` : state.status_label)
    })
  }

  async manual(event) {
    event.preventDefault()
    if (this.requesting || !this.configured) return
    clearTimeout(this.timer)
    this.requesting = true
    this.request = new AbortController()
    const button = event.submitter
    if (button) button.disabled = true
    this.messageTarget.textContent = "Sincronizando com GitHub…"
    try {
      const { data } = await this.json(event.target.action, { method: "POST", body: new FormData(event.target) })
      if (this.connected) this.messageTarget.textContent = data.message || "Tentativa concluída."
      this.channel?.postMessage("changed")
    } catch (error) {
      if (error.name !== "AbortError" && this.connected) this.messageTarget.textContent = error.message
    } finally {
      this.requesting = false
      if (button) button.disabled = !this.configured
      this.refresh()
    }
  }
}
