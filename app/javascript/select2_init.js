import $ from "jquery"
import select2 from "select2"

// Initialize select2 plugin on jQuery
select2($)

const SELECT2_OPTIONS = {
  width: "100%",
  minimumResultsForSearch: 0,
  language: {
    noResults: () => "Nenhum resultado encontrado",
    searching: () => "Buscando..."
  }
}

export function initSelect2(container = document) {
  // Defer to next frame so the browser paints the page first
  requestAnimationFrame(() => {
    const selects = container.querySelectorAll(
      "select.app-form-select:not(.select2-hidden-accessible), select.form-select:not(.select2-hidden-accessible)"
    )

    const isModal = container.closest?.("#appModal") || container.id === "app-modal-body"

    selects.forEach((el) => {
      const options = { ...SELECT2_OPTIONS }

      // Inside modal: attach dropdown to modal body so z-index works
      if (isModal) {
        const modalBody = document.getElementById("app-modal-body")
        if (modalBody) options.dropdownParent = $(modalBody)
      }

      $(el).select2(options)

      // Select2 triggers jQuery events only; dispatch a native event
      // so that vanilla addEventListener handlers (expense_form, etc.) work.
      $(el).on("change.select2bridge", function () {
        this.dispatchEvent(new Event("change", { bubbles: true }))
      })
    })
  })
}

function destroySelect2() {
  document.querySelectorAll("select.select2-hidden-accessible").forEach((el) => {
    $(el).select2("destroy")
  })
}

// Initialize on page load and Turbo navigation
document.addEventListener("turbo:load", () => initSelect2())
document.addEventListener("turbo:before-cache", destroySelect2)

// Initialize on Turbo frame renders
document.addEventListener("turbo:frame-load", (event) => {
  // Skip modal frame — handled separately in modal_turbo.js
  if (event.target.id === "modal") return
  initSelect2(event.target)
})
