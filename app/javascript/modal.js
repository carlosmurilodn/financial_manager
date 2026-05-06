// Modal próprio integrado ao Turbo.
// Responsável por abrir, fechar e limpar conteúdo dinâmico.

const bodyClass = "app-modal-open"

function getModal() {
  return document.getElementById("appModal")
}

function getModalContent() {
  return document.getElementById("app-modal-body")
}

function openModal() {
  const modal = getModal()
  if (!modal) return

  modal.classList.add("app-modal--open")
  document.body.classList.add(bodyClass)
}

function closeModal() {
  const modal = getModal()
  const content = getModalContent()

  if (!modal) return

  modal.classList.remove("app-modal--open")
  document.body.classList.remove(bodyClass)

  if (content) {
    content.innerHTML = ""
  }
}

function handleBackdropClick(event) {
  if (event.target.dataset.modalBackdrop === "true") {
    closeModal()
  }
}

function handleEscape(event) {
  if (event.key === "Escape") {
    closeModal()
  }
}

function bindModalEvents() {
  const modal = getModal()

  if (!modal || modal.dataset.modalBound === "true") return

  modal.dataset.modalBound = "true"

  modal.addEventListener("click", handleBackdropClick)
  document.addEventListener("keydown", handleEscape)
}

document.addEventListener("turbo:load", bindModalEvents)

document.addEventListener("turbo:frame-load", (event) => {
  if (event.target.id === "modal") {
    openModal()
  }
})

document.addEventListener("click", (event) => {
  const closeTrigger = event.target.closest("[data-close-modal]")

  if (closeTrigger) {
    closeModal()
  }
})

window.AppModal = {
  open: openModal,
  close: closeModal
}
