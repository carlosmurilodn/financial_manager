import { Controller } from "@hotwired/stimulus"
import $ from "jquery"

export default class extends Controller {
  static targets = ["tab", "panel", "daySelect"]

  selectDay(event) {
    this.activate(Number(event.currentTarget.value))
  }

  refreshOptions() {
    if (!this.hasDaySelectTarget) return
    Array.from(this.daySelectTarget.options).forEach((option, index) => {
      const calories = this.tabTargets[index].querySelector(".nutrition-week__tab-calories").textContent
      const updated = option.cloneNode(true)
      updated.textContent = `${option.dataset.label} · ${calories}`
      updated.selected = option.selected
      option.replaceWith(updated)
    })
    $(this.daySelectTarget).trigger("change.select2")
  }

  select(event) {
    this.activate(this.tabTargets.indexOf(event.currentTarget))
  }

  navigate(event) {
    const index = this.tabTargets.indexOf(event.currentTarget)
    const last = this.tabTargets.length - 1
    let next

    switch (event.key) {
      case "ArrowRight": next = index === last ? 0 : index + 1; break
      case "ArrowLeft": next = index === 0 ? last : index - 1; break
      case "Home": next = 0; break
      case "End": next = last; break
      default: return
    }

    event.preventDefault()
    this.activate(next)
    this.tabTargets[next].focus()
  }

  activate(index) {
    this.tabTargets.forEach((tab, position) => {
      const selected = position === index
      tab.setAttribute("aria-selected", String(selected))
      tab.tabIndex = selected ? 0 : -1
      this.panelTargets[position].hidden = !selected
    })
    if (this.hasDaySelectTarget) {
      this.daySelectTarget.value = String(index)
      $(this.daySelectTarget).trigger("change.select2")
    }
    if (this.tabTargets[index].getClientRects().length) {
      this.tabTargets[index].scrollIntoView({ block: "nearest", inline: "nearest" })
    }
  }
}
