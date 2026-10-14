import { Controller } from "@hotwired/stimulus"
import { showConfirmDialog } from "../confirm_dialog"

const NUTRIENTS = { calories: "Calorias (kcal)", carbohydrates: "Carboidratos (g)", proteins: "Proteínas (g)", fats: "Gorduras (g)" }
const SOURCES = { taco: "TACO", tabnut: "TabNut", custom: "Meus Alimentos", recipe: "Receitas" }

export default class extends Controller {
  static targets = ["dialog", "source", "query", "results", "status", "managementStatus", "totals", "summary", "done", "registrationDialog", "registrationTitle", "registrationStatus", "registrationBody"]
  static values = { searchUrl: String, saveUrl: String }

  connect() {
    this.states ||= new Map()
    this.formatter = new Intl.NumberFormat("pt-BR", { maximumFractionDigits: 2 })
  }

  disconnect() {
    clearTimeout(this.searchTimer)
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

  closeOutside(event) {
    const dialog = event.currentTarget
    if (event.target !== dialog) return
    const bounds = dialog.getBoundingClientRect()
    if (event.clientX >= bounds.left && event.clientX <= bounds.right && event.clientY >= bounds.top && event.clientY <= bounds.bottom) return

    if (dialog === this.registrationDialogTarget) this.cancelRegistration(event)
    else this.close()
  }

  async search(event) {
    event?.preventDefault()
    clearTimeout(this.searchTimer)
    this.searchRequest?.abort()
    const name = this.queryTarget.value.trim()
    if (!name) {
      this.resultsTarget.replaceChildren()
      this.setStatus("")
      return
    }
    this.searchRequest?.abort()
    this.searchRequest = new AbortController()
    const url = new URL(this.searchUrlValue, window.location.origin)
    url.searchParams.set("name", name)
    const source = this.selectedSource
    url.searchParams.set("source", source)
    this.setStatus("Pesquisando…")
    try {
      const response = await fetch(url, { headers: { Accept: "application/json" }, signal: this.searchRequest.signal })
      const data = await response.json()
      if (!response.ok) throw new Error(data.error || "Não foi possível pesquisar.")
      if (name !== this.queryTarget.value.trim() || source !== this.selectedSource) return
      this.resultsTarget.replaceChildren()
      data.foods.forEach(food => this.renderFood(food))
      this.setStatus(data.foods.length ? "Valores para a quantidade informada. Até 10 resultados por origem; refine a pesquisa se necessário." : "Nenhum resultado encontrado.")
      if (data.warning) this.setStatus(`${data.warning} Resultados locais disponíveis.`, true)
      this.updateBusyState()
    } catch (error) {
      if (error.name !== "AbortError") this.setStatus(error.message === "Failed to fetch" ? "Não foi possível pesquisar. Dados anteriores preservados." : error.message, true)
    }
  }

  get selectedSource() {
    return this.sourceTargets.find(input => input.checked)?.value || "all"
  }

  scheduleSearch() {
    clearTimeout(this.searchTimer)
    this.searchRequest?.abort()
    if (!this.queryTarget.value.trim()) {
      this.resultsTarget.replaceChildren()
      this.setStatus("")
      return
    }
    this.searchTimer = setTimeout(() => this.search(), 300)
  }

  renderFood(food) {
    if (food.needs_details) return this.renderTabNutSummary(food)

    const key = `${food.source}:${food.id}`
    if (!this.states.has(key)) this.states.set(key, { quantity: "100", unit: "grams", quantities: { grams: "100", servings: "1" }, token: null, uncertain: false })
    const state = this.states.get(key)
    const portionGrams = Number(food.portion_grams)
    const supportsServings = food.source === "recipe" && Number.isFinite(portionGrams) && portionGrams > 0
    if (!supportsServings && state.unit === "servings" && !state.uncertain) {
      state.unit = "grams"
      state.quantity = state.quantities.grams
    }
    const card = document.createElement("article")
    card.className = "nutrition-meal-picker__result"
    card.dataset.key = key
    const title = document.createElement("strong")
    title.textContent = food.name
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
    const conversion = document.createElement("small")
    let unitSelect
    if (supportsServings) {
      const unitField = document.createElement("div")
      unitField.className = "app-filter-field"
      const unitLabel = document.createElement("label")
      unitLabel.textContent = "Unidade"
      unitSelect = document.createElement("select")
      unitSelect.id = `${input.id}-unit`
      unitLabel.htmlFor = unitSelect.id
      unitSelect.className = "app-form-select"
      unitSelect.dataset.unit = "true"
      for (const [value, text] of [["grams", "Gramas"], ["servings", "Porções"]]) {
        const option = document.createElement("option")
        option.value = value
        option.textContent = text
        unitSelect.append(option)
      }
      unitSelect.value = state.unit
      unitSelect.disabled = state.uncertain
      unitField.append(unitLabel, unitSelect)
      actions.prepend(unitField)
    }
    const metrics = document.createElement("div")
    metrics.className = "nutrition-recipe-result__nutrients"
    const values = {}
    Object.entries(NUTRIENTS).forEach(([nutrient, text]) => {
      const wrapper = document.createElement("span")
      wrapper.className = `nutrition-recipe-result__badge nutrition-recipe-result__badge--${nutrient}`
      const term = document.createElement("span")
      term.textContent = `${text}: `
      values[nutrient] = document.createElement("span")
      wrapper.append(term, values[nutrient])
      metrics.append(wrapper)
    })
    const preview = () => {
      const quantity = Number(state.quantity)
      label.textContent = state.unit === "servings" ? "Quantidade (porções)" : "Quantidade (g)"
      const rawGrams = state.unit === "servings" ? quantity * portionGrams : quantity
      const grams = Number.isFinite(rawGrams) && rawGrams > 0 ? Number(rawGrams.toFixed(4)) : null
      conversion.textContent = supportsServings ? `1 porção = ${this.formatter.format(portionGrams)} g · Equivale a ${grams > 0 ? this.formatter.format(grams) : "—"} g` : ""
      Object.keys(NUTRIENTS).forEach(nutrient => {
        const value = food.nutrients[nutrient]
        const amount = value != null && grams > 0 ? Number(value) * grams / 100 : null
        values[nutrient].textContent = amount != null && Number.isFinite(amount) ? this.formatter.format(amount) : "—"
      })
    }
    input.addEventListener("input", () => {
      state.quantity = input.value
      state.quantities[state.unit] = input.value
      preview()
    })
    unitSelect?.addEventListener("change", () => {
      state.quantities[state.unit] = state.quantity
      state.unit = unitSelect.value
      state.quantity = state.quantities[state.unit]
      input.value = state.quantity
      preview()
    })
    preview()
    const identity = document.createElement("div")
    identity.className = "nutrition-recipe-result__identity"
    title.textContent = `${food.name} · ${SOURCES[food.source]}${food.data_source ? ` · ${food.data_source}` : ""}`
    identity.append(title, metrics)
    card.append(identity, actions, conversion)
    this.resultsTarget.append(card)
    return card
  }

  renderTabNutSummary(food) {
    const card = document.createElement("article")
    card.className = "nutrition-meal-picker__result"
    const title = document.createElement("strong")
    title.textContent = `${food.name} · TabNut · ${food.data_source || ""} · ${food.serving || ""}`
    const button = document.createElement("button")
    button.type = "button"
    button.className = "app-btn app-btn--outline"
    button.dataset.add = "true"
    button.textContent = "Carregar dados"
    button.addEventListener("click", async () => {
      if (this.saving) return
      button.disabled = true
      this.setStatus("Carregando nutrientes TabNut…")
      try {
        const url = new URL(this.searchUrlValue, window.location.origin)
        url.searchParams.set("source", "tabnut")
        url.searchParams.set("source_id", food.id)
        const response = await fetch(url, { headers: { Accept: "application/json" } })
        const data = await response.json()
        if (!response.ok) throw new Error(data.error || "Não foi possível carregar TabNut.")
        if (!card.isConnected) return
        const detailed = this.renderFood(data.foods[0])
        card.replaceWith(detailed)
        this.setStatus("Confira nutrientes e quantidade antes de adicionar à refeição.")
        this.updateBusyState()
      } catch (error) {
        this.setStatus(error.message, true)
      } finally {
        button.disabled = Boolean(this.saving)
      }
    })
    card.append(title, button)
    this.resultsTarget.append(card)
    return card
  }

  async newRegistration(event) {
    if (this.saving || this.registrationLoading) return
    const button = event.currentTarget
    clearTimeout(this.searchTimer)
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
        body: JSON.stringify({ nutrition_meal_item: { source: food.source, source_id: food.id, quantity: state.quantity, unit: state.unit, request_token: state.token } })
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
    if (this.hasTotalsTarget) this.totalsTarget.innerHTML = data.totals_html

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
    this.resultsTarget.querySelectorAll("[data-unit]").forEach(select => {
      const state = this.states.get(select.closest("[data-key]").dataset.key)
      select.disabled = Boolean(this.saving) || state.uncertain
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
