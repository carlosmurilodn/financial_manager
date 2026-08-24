import $ from "jquery"
import select2 from "select2"

// Initialize select2 plugin on jQuery
select2($)

function initSelect2() {
  document.querySelectorAll("select.app-form-select:not(.select2-hidden-accessible), select.form-select:not(.select2-hidden-accessible)").forEach((el) => {
    $(el).select2({
      width: "100%",
      minimumResultsForSearch: 0,
      language: {
        noResults: () => "Nenhum resultado encontrado",
        searching: () => "Buscando..."
      }
    })
  })
}

function destroySelect2() {
  document.querySelectorAll("select.select2-hidden-accessible").forEach((el) => {
    $(el).select2("destroy")
  })
}

// Initialize on page load and Turbo navigation
document.addEventListener("turbo:load", initSelect2)
document.addEventListener("turbo:before-cache", destroySelect2)

// Initialize on Turbo frame renders
document.addEventListener("turbo:frame-load", initSelect2)
