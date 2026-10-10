import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["viewport", "pages", "navigation", "counter", "previous", "next"]

  connect() {
    this.page = 0
    this.total = 1
    this.element.classList.add("is-paginated")
    this.navigationTarget.hidden = false
    this.observer = new ResizeObserver(() => this.scheduleLayout())
    this.observer.observe(this.viewportTarget)
    this.scheduleLayout()
    document.fonts?.ready.then(() => {
      if (this.element.isConnected) this.scheduleLayout()
    })
  }

  disconnect() {
    this.observer?.disconnect()
    cancelAnimationFrame(this.frame)
    this.element.classList.remove("is-paginated")
    this.navigationTarget.hidden = true
    this.pagesTarget.style.removeProperty("transform")
  }

  scheduleLayout() {
    cancelAnimationFrame(this.frame)
    this.frame = requestAnimationFrame(() => this.layout())
  }

  layout() {
    const width = this.viewportTarget.clientWidth
    if (!width) return

    const progress = this.total > 1 ? this.page / (this.total - 1) : 0
    this.pagesTarget.style.transform = "none"
    this.pagesTarget.style.columnWidth = `${width}px`
    this.step = width + parseFloat(getComputedStyle(this.pagesTarget).columnGap)
    this.total = Math.max(1, Math.round((this.pagesTarget.scrollWidth + this.step - width) / this.step))
    this.page = Math.round(progress * (this.total - 1))
    this.showPage()
  }

  previous() {
    this.page = Math.max(0, this.page - 1)
    this.showPage()
  }

  next() {
    this.page = Math.min(this.total - 1, this.page + 1)
    this.showPage()
  }

  navigate(event) {
    if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return
    if (event.target.closest("input, textarea, select, [contenteditable]")) return
    if (event.key === "ArrowLeft") {
      event.preventDefault()
      this.previous()
    } else if (event.key === "ArrowRight") {
      event.preventDefault()
      this.next()
    }
  }

  showPage() {
    if (!this.step) return
    this.pagesTarget.style.transform = `translateX(-${this.page * this.step}px)`
    this.counterTarget.textContent = `Página ${this.page + 1} de ${this.total}`
    this.previousTarget.disabled = this.page === 0
    this.nextTarget.disabled = this.page === this.total - 1
  }
}
