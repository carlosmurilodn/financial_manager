const pending = new Set()

function update() {
  const indicator = document.getElementById("app-page-loading")
  if (indicator) indicator.hidden = pending.size === 0
}

function start(key) {
  pending.add(key)
  update()
}

function finish(key) {
  pending.delete(key)
  update()
}

function reset() {
  pending.clear()
  update()
}

document.addEventListener("turbo:visit", () => start("visit"))
document.addEventListener("turbo:load", () => {
  reset()
  if (document.readyState !== "complete") start("initial")
})
document.addEventListener("turbo:before-cache", reset)
document.addEventListener("turbo:submit-start", event => start(event.target))
document.addEventListener("turbo:submit-end", event => finish(event.target))
document.addEventListener("turbo:before-fetch-request", event => {
  if (event.target instanceof HTMLElement && event.target.matches("turbo-frame")) start(event.target)
})
document.addEventListener("turbo:frame-load", event => finish(event.target))
document.addEventListener("turbo:before-fetch-response", event => {
  // Empty and stream responses do not always emit turbo:frame-load.
  if (event.target instanceof HTMLElement && event.target.matches("turbo-frame")) finish(event.target)
})
document.addEventListener("turbo:frame-missing", event => finish(event.target))
document.addEventListener("turbo:fetch-request-error", event => {
  finish(event.target)
  if (event.target === document.documentElement) finish("visit")
})

// Native navigation includes links and forms with data-turbo="false".
if (window.navigation) {
  window.navigation.addEventListener("navigate", event => {
    if (event.hashChange || event.downloadRequest !== null || event.destination.sameDocument) return
    start("native")
    event.signal.addEventListener("abort", () => finish("native"), { once: true })
  })
  window.navigation.addEventListener("navigateerror", reset)
} else {
  window.addEventListener("beforeunload", () => start("native"))
  // Returning focus after cancelling the browser's leave-page prompt.
  window.addEventListener("focus", () => finish("native"))
}

window.addEventListener("pageshow", reset)
window.addEventListener("load", () => finish("initial"), { once: true })
if (document.readyState !== "complete") start("initial")
