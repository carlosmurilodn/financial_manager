import { Controller } from "@hotwired/stimulus"
import { showConfirmDialog } from "../confirm_dialog"

const NUTRIENTS = { calories: "Calorias (kcal)", carbohydrates: "Carboidratos (g)", proteins: "Proteínas (g)", fats: "Gorduras (g)" }
const SOURCES = { taco: "TACO", custom: "Meus Alimentos", recipe: "Receitas" }

export default class extends Controller {
  static targets = ["dialog", "source", "query", "results", "status", "managementStatus", "summary", "done", "registrationDialog", "registrationTitle", "registrationStatus", "registrationBody"]
  static values = { searchUrl: String, saveUrl: String }

  connect() {
    this.states ||= new Map()
    this.formatter = new Intl.NumberFormat("pt-BR", { maximumFractionDigits: 2 })
  }

  disconnect() {
    this.searchRequest?.abort()
    this.registrationRequest?.abort()
    this.registrationDialogTarget.close()
    this.dialogTarget.close()
  }

  open(event) {
    this.opener = event.currentTarget
    this.dialogTarget.showModal()
    this.queryTarget.focus()
  }

  close() {
    if (this.saving) return
    this.dialogTarget.close()
    this.opener?.focus()
  }

  cancel(event) {
    event.preventDefault()
    this.close()
  }

  async search(event) {
    event.preventDefault()
    const name = this.queryTarget.value.trim()
    if (!name) {
      this.setStatus("Informe um nome para pesquisar.")
      return
    }
    this.searchRequest?.abort()
    this.searchRequest = new AbortController()
    const url = new URL(this.searchUrlValue, window.location.origin)
    url.searchParams.set("name", name)
    url.searchParams.set("source", this.sourceTarget.value)
    this.setStatus("Pesquisando…")
    try {
      const response = await fetch(url, { headers: { Accept: "application/json" }, signal: this.searchRequest.signal })
      if (!response.ok) throw new Error("search failed")
      const data = await response.json()
      this.resultsTarget.replaceChildren()
      data.foods.forEach(food => this.renderFood(food))
      this.setStatus(data.foods.length ? "Valores para a quantidade informada. Até 10 resultados por origem; refine a pesquisa se necessário." : "Nenhum resultado encontrado.")
      this.updateBusyState()
    } catch (error) {
      if (error.name !== "AbortError") this.setStatus("Não foi possível pesquisar. Dados anteriores preservados.", true)
    }
  }

  renderFood(food) {
    const key = `${food.source}:${food.id}`
    if (!this.states.has(key)) this.states.set(key, { quantity: "100", token: null, uncertain: false })
    const state = this.states.get(key)
    const card = document.createElement("article")
    card.className = "nutrition-meal-picker__result"
    card.dataset.key = key
    const title = document.createElement("strong")
    title.textContent = food.name
    const origin = document.createElement("small")
    origin.textContent = SOURCES[food.source]
    const actions = document.createElement("div")
    actions.className = "nutrition-meal-picker__result-actions"
    const field = document.createElement("div")
    field.className = "app-filter-field"
    const label = document.createElement("label")
    label.textContent = "Quantidade (g)"
    const input = document.createElement("input")
    input.id = `${this.dialogTarget.querySelector("h2").id}-${food.source}-${food.id}`
    label.htmlFor = input.id
    input.type = "number"
    input.className = "app-form-control"
    input.min = "0.0001"
    input.max = "99999999.9999"
    input.step = "0.0001"
    input.required = true
    input.value = state.quantity
    input.readOnly = state.uncertain
    input.dataset.quantity = "true"
    const button = document.createElement("button")
    button.type = "button"
    button.className = "app-btn app-btn--primary"
    button.dataset.add = "true"
    button.textContent = "+"
    button.title = "Adicionar à refeição"
    button.setAttribute("aria-label", `Adicionar ${food.name}`)
    button.addEventListener("click", () => this.save(food, state, input))
    field.append(label, input)
    actions.append(field, button)
    const metrics = document.createElement("dl")
    metrics.className = "exercise-entry-show__details"
    const values = {}
    Object.entries(NUTRIENTS).forEach(([nutrient, text]) => {
      const wrapper = document.createElement("div")
      const term = document.createElement("dt")
      term.textContent = text
      values[nutrient] = document.createElement("dd")
      wrapper.append(term, values[nutrient])
      metrics.append(wrapper)
    })
    const preview = () => {
      const quantity = Number(state.quantity)
      Object.keys(NUTRIENTS).forEach(nutrient => {
        const value = food.nutrients[nutrient]
        const amount = value != null && Number.isFinite(quantity) && quantity > 0 ? Number(value) * quantity / 100 : null
        values[nutrient].textContent = amount != null && Number.isFinite(amount) ? this.formatter.format(amount) : "—"
      })
    }
    input.addEventListener("input", () => { state.quantity = input.value; preview() })
    preview()
    card.append(title, origin, actions, metrics)
    this.resultsTarget.append(card)
    return card
  }

  async newRegistration(event) {
    if (this.saving || this.registrationLoading) return
    const button = event.currentTarget
    this.searchRequest?.abort()
    this.registrationTitleTarget.textContent = button.dataset.registrationTitle
    this.registrationDialogTarget.showModal()
    if (this.registrationUrl === button.dataset.url && this.registrationBodyTarget.querySelector("form")) {
      this.registrationBodyTarget.querySelector("input:not([type='hidden'])")?.focus()
      return
    }

    this.registrationLoading = true
    this.registrationRequest = new AbortController()
    this.registrationBodyTarget.replaceChildren()
    this.registrationStatusTarget.textContent = "Carregando formulário…"
    try {
      const response = await fetch(button.dataset.url, { headers: { Accept: "text/html" }, signal: this.registrationRequest.signal })
      if (!response.ok) throw new Error("form failed")
      this.registrationBodyTarget.innerHTML = await response.text()
      this.registrationUrl = button.dataset.url
      this.registrationStatusTarget.textContent = "O cadastro só será vinculado à refeição após clicar em +."
      this.registrationBodyTarget.querySelector("input:not([type='hidden'])")?.focus()
    } catch (error) {
      if (error.name !== "AbortError") this.registrationStatusTarget.textContent = "Não foi possível abrir o formulário. Volte à pesquisa e tente novamente."
    } finally {
      this.registrationLoading = false
    }
  }

  cancelRegistration(event) {
    event?.preventDefault()
    if (this.saving) return
    this.registrationRequest?.abort()
    this.registrationDialogTarget.close()
    this.queryTarget.focus()
  }

  async saveRegistration(event) {
    event.preventDefault()
    if (this.saving) return
    const form = event.currentTarget
    if (!form.reportValidity()) return
    const body = new FormData(form)
    this.saving = true
    form.inert = true
    this.updateBusyState()
    this.registrationStatusTarget.textContent = "Salvando cadastro…"
    try {
      const response = await fetch(form.action, {
        method: "POST", body,
        headers: { Accept: "application/json, text/html", "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content }
      })
      if (response.status === 422) {
        const template = document.createElement("template")
        template.innerHTML = await response.text()
        const errors = template.content.querySelector("[data-registration-errors]")
        if (errors) this.registrationBodyTarget.querySelector("[data-registration-errors]").innerHTML = errors.innerHTML
        this.registrationStatusTarget.textContent = "Revise os campos indicados. Dados informados preservados."
        return
      }
      if (!response.ok) throw new Error("registration failed")
      const data = await response.json()
      this.registrationDialogTarget.close()
      this.registrationBodyTarget.replaceChildren()
      this.registrationUrl = null
      this.resultsTarget.querySelectorAll(".is-selected").forEach(row => row.classList.remove("is-selected"))
      const row = this.renderFood(data.food)
      this.resultsTarget.prepend(row)
      row.classList.add("is-selected")
      const quantity = row.querySelector("[data-quantity]")
      quantity.focus()
      quantity.select()
      row.scrollIntoView({ block: "nearest" })
      this.setStatus(data.message)
    } catch (error) {
      this.registrationStatusTarget.textContent = "Não foi possível confirmar o cadastro. Formulário, pesquisa e itens anteriores preservados."
    } finally {
      this.saving = false
      form.inert = false
      this.updateBusyState()
    }
  }

  async save(food, state, input) {
    if (this.saving || !input.reportValidity()) return
    this.saving = true
    state.token ||= crypto.randomUUID()
    this.updateBusyState()
    this.setStatus("Salvando item…")
    let confirmed = false
    try {
      const response = await fetch(this.saveUrlValue, {
        method: "POST",
        headers: { Accept: "application/json", "Content-Type": "application/json", "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content },
        body: JSON.stringify({ nutrition_meal_item: { source: food.source, source_id: food.id, quantity_grams: state.quantity, request_token: state.token } })
      })
      const data = await response.json()
      confirmed = response.ok || response.status === 422
      if (!response.ok) throw new Error(data.error || "Não foi possível salvar.")
      this.applyResponse(data)
      state.token = null
      state.uncertain = false
      this.setStatus(data.message)
    } catch (error) {
      state.uncertain = !confirmed
      if (confirmed) state.token = null
      this.setStatus(confirmed ? error.message : "Resposta não confirmada. Clique em + novamente para confirmar a mesma inclusão sem duplicar. Pesquisa e quantidade foram preservadas.", true)
    } finally {
      this.saving = false
      this.updateBusyState()
    }
  }

  updateItem(event) {
    event.preventDefault()
    const form = event.currentTarget
    if (!form.reportValidity()) return
    this.manage(form.action, "PATCH", new FormData(form))
  }

  deleteItem(event) {
    const button = event.currentTarget
    this.manage(button.dataset.url, "DELETE", null, button)
  }

  deleteMeal(event) {
    const button = event.currentTarget
    this.manage(button.dataset.url, "DELETE", null, button, true)
  }

  async manage(url, method, body, confirmation = null, removeMeal = false) {
    if (this.saving) return
    this.saving = true
    this.updateBusyState()
    try {
      if (confirmation && !await showConfirmDialog(confirmation.dataset.turboConfirm, confirmation)) return
      this.setStatus("Atualizando refeição…")
      const response = await fetch(url, {
        method, body,
        headers: { Accept: "application/json", "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content }
      })
      const data = await response.json()
      if (!response.ok) throw new Error(data.error || "Não foi possível atualizar a refeição.")
      if (removeMeal) {
        const day = this.element.closest("[data-controller~='nutrition-meal-form']")
        this.dialogTarget.close()
        this.element.remove()
        day.dispatchEvent(new CustomEvent("nutrition-meals:changed", { detail: data }))
      } else {
        this.applyResponse(data)
        this.setStatus(data.message)
      }
    } catch (error) {
      this.setStatus(error.message === "Failed to fetch" ? "Falha de conexão. Dados informados preservados; tente novamente." : error.message, true)
    } finally {
      this.saving = false
      this.updateBusyState()
    }
  }

  applyResponse(data) {
    this.summaryTargets.forEach(summary => {
      summary.innerHTML = summary.closest("dialog") ? data.picker_html : data.html
    })
    this.element.dispatchEvent(new CustomEvent("nutrition-meals:changed", { bubbles: true, detail: data }))
  }

  updateBusyState() {
    this.doneTarget.disabled = Boolean(this.saving)
    this.resultsTarget.querySelectorAll("[data-add]").forEach(button => { button.disabled = Boolean(this.saving) })
    this.resultsTarget.querySelectorAll("[data-quantity]").forEach(input => {
      const state = this.states.get(input.closest("[data-key]").dataset.key)
      input.disabled = Boolean(this.saving)
      input.readOnly = state.uncertain
    })
    this.element.querySelectorAll(".nutrition-meal-item-quantity button, .nutrition-meal-item-quantity input[type='number'], [data-action='meal-picker#deleteItem'], [data-action='meal-picker#deleteMeal']").forEach(control => {
      control.disabled = Boolean(this.saving)
    })
    this.element.querySelectorAll("[data-action='meal-picker#newRegistration'], [data-action='meal-picker#cancelRegistration']").forEach(control => {
      control.disabled = Boolean(this.saving)
    })
  }

  setStatus(message, error = false) {
    this.statusTarget.textContent = message
    this.statusTarget.classList.toggle("is-error", error)
    this.managementStatusTarget.textContent = message
    this.managementStatusTarget.classList.toggle("is-error", error)
  }
}
