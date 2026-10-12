import { Controller } from "@hotwired/stimulus"

const NUTRIENTS = ["calories", "carbohydrates", "proteins", "fats"]

export default class extends Controller {
  static targets = ["source", "query", "results", "status", "items", "template", "ingredient", "weight", "servings", "total"]
  static values = { searchUrl: String }

  connect() {
    this.sequence = 0
    this.formatter = new Intl.NumberFormat("pt-BR", { maximumFractionDigits: 2 })
    this.update()
  }

  disconnect() {
    clearTimeout(this.searchTimer)
    this.request?.abort()
  }

  scheduleSearch() {
    clearTimeout(this.searchTimer)
    this.clearResults()
    if (!this.queryTarget.value.trim()) return

    this.searchTimer = setTimeout(() => this.search(), 300)
  }

  clearResults() {
    this.request?.abort()
    this.resultsTarget.replaceChildren()
    this.statusTarget.textContent = ""
  }

  async search(event) {
    event?.preventDefault()
    clearTimeout(this.searchTimer)
    this.clearResults()
    const query = this.queryTarget.value.trim()
    if (!query) {
      this.statusTarget.textContent = "Informe o nome do alimento para pesquisar."
      this.queryTarget.focus()
      return
    }

    const source = this.sourceTargets.find(input => input.checked).value
    const url = new URL(this.searchUrlValue, window.location.origin)
    url.searchParams.set("source", source)
    url.searchParams.set("name", query)
    this.request = new AbortController()
    this.statusTarget.textContent = "Pesquisando alimentos…"

    try {
      const response = await fetch(url, { headers: { Accept: "application/json" }, signal: this.request.signal })
      if (!response.ok) throw new Error("search failed")
      const foods = await response.json()
      if (query !== this.queryTarget.value.trim() || source !== this.sourceTargets.find(input => input.checked).value) return
      this.statusTarget.textContent = foods.length ? "Selecione um alimento. Até 20 resultados; refine a pesquisa se necessário." : "Nenhum alimento encontrado."
      foods.forEach(food => {
        const row = document.createElement("div")
        row.className = "nutrition-recipe-result"
        const name = document.createElement("strong")
        name.textContent = `${food.name} · ${food.source === "custom" ? "Meus Alimentos" : "TACO"}`
        const nutrients = document.createElement("div")
        nutrients.className = "nutrition-recipe-result__nutrients"
        nutrients.setAttribute("aria-label", "Valores nutricionais por 100 g")
        Object.entries({ calories: ["Calorias", "kcal"], carbohydrates: ["Carboidratos", "g"], proteins: ["Proteínas", "g"], fats: ["Gorduras", "g"] }).forEach(([field, [label, unit]]) => {
          const metric = document.createElement("span")
          metric.className = `nutrition-recipe-result__badge nutrition-recipe-result__badge--${field}`
          const value = food[field] == null ? null : Number(food[field])
          metric.textContent = `${label}: ${this.format(value)}${value === null ? "" : ` ${unit}`}`
          metric.title = `${label} por 100 g`
          nutrients.append(metric)
        })
        const button = document.createElement("button")
        button.type = "button"
        button.className = "app-btn app-btn--secondary"
        button.textContent = "Adicionar"
        button.setAttribute("aria-label", `Adicionar ${food.name}`)
        button.addEventListener("click", () => this.add(food, food.source))
        const identity = document.createElement("div")
        identity.className = "nutrition-recipe-result__identity"
        identity.append(name, nutrients)
        row.append(identity, button)
        this.resultsTarget.append(row)
      })
    } catch (error) {
      if (error.name !== "AbortError") this.statusTarget.textContent = "Não foi possível pesquisar. Tente novamente."
    }
  }

  add(food, source) {
    const fragment = document.createElement("template")
    fragment.innerHTML = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", `${Date.now()}${this.sequence++}`)
    const row = fragment.content.querySelector("[data-nutrition-recipe-form-target='ingredient']")
    row.dataset.nutrients = JSON.stringify(Object.fromEntries(NUTRIENTS.map(field => [field, food[field]])))
    row.querySelector("[data-ingredient-field='source']").value = source
    row.querySelector("[data-ingredient-field='source_id']").value = food.id
    row.querySelector("[data-ingredient-name]").textContent = food.name
    row.querySelector("[data-ingredient-source]").textContent = source === "custom" ? "Meus Alimentos" : "TACO"
    const quantity = row.querySelector("[data-ingredient-field='quantity']")
    quantity.value = "100"
    this.itemsTarget.append(fragment.content)
    this.update()
    quantity.focus()
    this.statusTarget.textContent = `${food.name} adicionado.`
  }

  remove(event) {
    const row = event.currentTarget.closest("[data-nutrition-recipe-form-target='ingredient']")
    row.querySelector("[data-ingredient-field='destroy']").value = "1"
    row.querySelector("[data-ingredient-field='quantity']").disabled = true
    row.hidden = true
    this.update()
  }

  update() {
    const rows = Array.from(this.itemsTarget.querySelectorAll("[data-nutrition-recipe-form-target='ingredient']"))
      .filter(row => row.querySelector("[data-ingredient-field='destroy']").value !== "1")
    const totals = Object.fromEntries(NUTRIENTS.map(field => [field, rows.length ? 0 : null]))

    rows.forEach(row => {
      const quantity = this.positiveNumber(row.querySelector("[data-ingredient-field='quantity']").value)
      const nutrients = JSON.parse(row.dataset.nutrients)
      NUTRIENTS.forEach(field => {
        const nutrient = nutrients[field] == null ? null : Number(nutrients[field])
        const amount = quantity && nutrient !== null && Number.isFinite(nutrient) ? nutrient * quantity / 100 : null
        row.querySelector(`[data-ingredient-nutrient='${field}']`).textContent = this.format(amount)
        totals[field] = totals[field] !== null && amount !== null ? totals[field] + amount : null
      })
    })

    const weight = this.positiveNumber(this.weightTarget.value)
    const servings = this.positiveNumber(this.servingsTarget.value)
    this.totalTargets.forEach(cell => {
      let value = totals[cell.dataset.nutrient]
      if (value !== null && cell.dataset.basis === "per_100g") value = weight ? value * 100 / weight : null
      if (value !== null && cell.dataset.basis === "per_serving") value = servings && Number.isInteger(servings) ? value / servings : null
      cell.textContent = this.format(value)
    })
  }

  positiveNumber(value) {
    const number = Number(value)
    return Number.isFinite(number) && number > 0 ? number : null
  }

  format(value) {
    return value !== null && Number.isFinite(value) ? this.formatter.format(value) : "—"
  }
}
