import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["frame"]
  static values = { url: String }

  connect() {
    this.timer = setInterval(() => this.refresh(), 10000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  refresh() {
    if (document.hidden || !this.hasFrameTarget) return
    const frame = this.frameTarget
    const outstanding = Number(frame.querySelector("[data-health-sync-outstanding]")?.dataset.healthSyncOutstanding || 0)
    if (!outstanding || frame.hasAttribute("busy") || frame.contains(document.activeElement)) return
    if (frame.src) frame.reload()
    else frame.src = this.urlValue
  }
}
