const FILTER_FORMS = "form.app-filter-form, form.writing-statistics-filters, form.evolution-period-form"

document.addEventListener("change", (event) => {
  const select = event.target
  if (!(select instanceof HTMLSelectElement) || !select.name || event.defaultPrevented) return

  const form = select.form
  if (!form?.matches(FILTER_FORMS) || form.method !== "get") return

  form.requestSubmit()
})
