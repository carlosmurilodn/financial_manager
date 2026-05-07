const AUTO_DISMISS_DELAY = 5000
const HIDE_TRANSITION_DELAY = 240

function dismissFlash(flash) {
  if (!flash || flash.dataset.flashDismissing === "true") return

  flash.dataset.flashDismissing = "true"
  flash.classList.add("is-hiding")

  window.setTimeout(() => {
    flash.remove()
  }, HIDE_TRANSITION_DELAY)
}

function initializeFlashMessages() {
  document.querySelectorAll(".app-flash").forEach((flash) => {
    if (flash.dataset.flashAutoDismissBound === "true") return

    flash.dataset.flashAutoDismissBound = "true"
    window.setTimeout(() => dismissFlash(flash), AUTO_DISMISS_DELAY)
  })
}

document.addEventListener("turbo:load", initializeFlashMessages)
document.addEventListener("turbo:frame-load", initializeFlashMessages)
document.addEventListener("DOMContentLoaded", initializeFlashMessages)
