const STORAGE_KEY = "financial_manager.calendar_tab"

const selectedTab = () => {
  try {
    return localStorage.getItem(STORAGE_KEY)
  } catch {
    return null
  }
}

const saveTab = (value) => {
  try {
    localStorage.setItem(STORAGE_KEY, value)
  } catch {
    // Ignore storage failures so tab switching still works normally.
  }
}

const applyCalendarTab = (root = document) => {
  root.querySelectorAll("[data-calendar-tabs]").forEach((tabs) => {
    const saved = selectedTab()
    const savedRadio = saved ? tabs.querySelector(`[data-calendar-tab-value="${saved}"]`) : null
    const fallbackRadio = tabs.querySelector("[data-calendar-tab-value]:checked")
    const radio = savedRadio || fallbackRadio

    if (radio) radio.checked = true
  })
}

document.addEventListener("change", (event) => {
  const input = event.target.closest("[data-calendar-tab-value]")

  if (!input) return

  saveTab(input.dataset.calendarTabValue)
})

document.addEventListener("turbo:load", () => {
  applyCalendarTab()
})

document.addEventListener("turbo:frame-load", (event) => {
  applyCalendarTab(event.target)
})
