import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

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
    this.tabTargets[index].scrollIntoView({ block: "nearest", inline: "nearest" })
  }
}
