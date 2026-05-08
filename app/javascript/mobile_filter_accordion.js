const mobileFilterQuery = window.matchMedia("(max-width: 767px)")

function syncMobileFilterAccordions(root = document, { forceMobileClosed = false } = {}) {
  root.querySelectorAll("[data-mobile-filter-accordion]").forEach((accordion) => {
    if (mobileFilterQuery.matches) {
      if (!forceMobileClosed && accordion.dataset.mobileFilterInitialized === "true") return

      accordion.open = false
      accordion.dataset.mobileFilterInitialized = "true"
      return
    }

    accordion.open = true
    delete accordion.dataset.mobileFilterInitialized
  })
}

document.addEventListener("turbo:load", () => syncMobileFilterAccordions(document, { forceMobileClosed: true }))
document.addEventListener("turbo:frame-load", (event) => syncMobileFilterAccordions(event.target))

mobileFilterQuery.addEventListener("change", () => syncMobileFilterAccordions(document, { forceMobileClosed: true }))
