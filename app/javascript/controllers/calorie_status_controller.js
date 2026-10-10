import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "status"]
  static values = { persisted: Boolean, saved: String }

  connect() {
    this.update()
  }

  update() {
    const current = this.normalize(this.inputTarget.value)
    const saved = this.persistedValue && current !== null && current === this.normalize(this.savedValue)

    this.statusTarget.textContent = saved ? "Registro salvo ✅" : "Registro pendente ❌"
  }

  saveDietStatus(event) {
    event.target.form.requestSubmit()
  }

  normalize(value) {
    const normalized = value.trim().replace(",", ".")
    if (normalized === "") return ""
    if (!/^\d+(?:\.\d{1,2})?$/.test(normalized)) return null

    const [integer, decimal = ""] = normalized.split(".")
    const whole = integer.replace(/^0+(?=\d)/, "")
    const fraction = decimal.replace(/0+$/, "")
    return fraction ? `${whole}.${fraction}` : whole
  }
}
