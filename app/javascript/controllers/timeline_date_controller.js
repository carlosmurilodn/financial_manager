import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mode", "exact", "reference", "relative"]

  connect() {
    this.refresh()
  }

  refresh() {
    const mode = this.modeTarget.value
    this.exactTarget.hidden = mode !== "exact"
    this.referenceTarget.hidden = !["approximate", "relative"].includes(mode)
    this.relativeTarget.hidden = mode !== "relative"
    this.exactTarget.querySelector("input").required = mode === "exact"
    this.referenceTarget.querySelector("input").required = ["approximate", "relative"].includes(mode)
  }
}
