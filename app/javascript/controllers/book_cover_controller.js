import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["preview", "error"]

  preview(event) {
    this.releaseUrl()
    this.previewTarget.hidden = true
    this.errorTarget.hidden = true
    const file = event.target.files[0]
    if (!file) return
    if (!["image/jpeg", "image/png", "image/webp"].includes(file.type) || file.size > 5 * 1024 * 1024) {
      this.errorTarget.textContent = "Selecione uma imagem JPEG, PNG ou WebP de até 5 MB."
      this.errorTarget.hidden = false
      event.target.value = ""
      return
    }
    this.objectUrl = URL.createObjectURL(file)
    this.previewTarget.src = this.objectUrl
    this.previewTarget.hidden = false
  }

  disconnect() {
    this.releaseUrl()
  }

  releaseUrl() {
    if (this.objectUrl) URL.revokeObjectURL(this.objectUrl)
    this.objectUrl = null
  }
}
