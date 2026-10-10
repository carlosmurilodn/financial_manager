import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["book", "styles", "style", "viewport", "pages", "navigation", "counter", "previous", "next"]

  connect() {
    this.page = 0
    this.total = 1
    this.preferredPages = 2
    try {
      if (localStorage.getItem("writing-reader-pages") === "1") this.preferredPages = 1
    } catch { /* Reading remains available when browser storage is blocked. */ }
    this.bookTarget.classList.add("is-paginated")
    this.updateStyle()
    this.stylesTarget.hidden = false
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
    this.bookTarget.classList.remove("is-paginated", "is-spread", "is-single")
    this.stylesTarget.hidden = true
    this.navigationTarget.hidden = true
    this.pagesTarget.style.removeProperty("transform")
    this.pagesTarget.style.removeProperty("width")
  }

  scheduleLayout() {
    cancelAnimationFrame(this.frame)
    this.frame = requestAnimationFrame(() => this.layout())
  }

  chooseStyle(event) {
    this.preferredPages = Number(event.currentTarget.dataset.pages)
    try {
      localStorage.setItem("writing-reader-pages", String(this.preferredPages))
    } catch { /* Keep the selected style for this visit without storage. */ }
    this.updateStyle()
    this.scheduleLayout()
  }

  updateStyle() {
    this.bookTarget.classList.toggle("is-single", this.preferredPages === 1)
    this.styleTargets.forEach(button => {
      button.setAttribute("aria-pressed", String(Number(button.dataset.pages) === this.preferredPages))
    })
  }

  layout() {
    const width = this.viewportTarget.clientWidth
    if (!width) return

    const progress = this.total > 1 ? this.page / (this.total - 1) : 0
    this.pagesPerView = this.preferredPages === 2 && width >= 1100 ? 2 : 1
    this.bookTarget.classList.toggle("is-spread", this.pagesPerView === 2)
    const gap = parseFloat(getComputedStyle(this.pagesTarget).columnGap)
    const columnWidth = (width - gap * (this.pagesPerView - 1)) / this.pagesPerView
    this.pagesTarget.style.transform = "none"
    this.pagesTarget.style.width = `${columnWidth}px`
    this.pagesTarget.style.columnWidth = `${columnWidth}px`
    this.step = columnWidth + gap
    this.total = Math.max(1, Math.round((this.pagesTarget.scrollWidth + gap) / this.step))
    const desiredPage = Math.round(progress * (this.total - 1))
    this.page = Math.floor(desiredPage / this.pagesPerView) * this.pagesPerView
    this.showPage()
  }

  previous() {
    this.page = Math.max(0, this.page - this.pagesPerView)
    this.showPage()
  }

  next() {
    if (this.page + this.pagesPerView >= this.total) return

    this.page += this.pagesPerView
    this.showPage()
    this.viewportTarget.focus({ preventScroll: true })
    this.element.scrollIntoView({ behavior: "instant", block: "start" })
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
    const lastVisiblePage = Math.min(this.total, this.page + this.pagesPerView)
    this.counterTarget.textContent = lastVisiblePage > this.page + 1
      ? `Páginas ${this.page + 1}–${lastVisiblePage} de ${this.total}`
      : `Página ${this.page + 1} de ${this.total}`
    this.previousTarget.disabled = this.page === 0
    this.nextTarget.disabled = this.page + this.pagesPerView >= this.total
  }
}
