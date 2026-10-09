import { Controller } from "@hotwired/stimulus"
import $ from "jquery"
import { initSelect2 } from "../select2_init"

export default class extends Controller {
  connect() {
    initSelect2(this.element)
  }

  disconnect() {
    this.element.querySelectorAll("select.select2-hidden-accessible").forEach((select) => {
      $(select).off("change.select2bridge")
      $(select).select2("destroy")
    })
  }
}
