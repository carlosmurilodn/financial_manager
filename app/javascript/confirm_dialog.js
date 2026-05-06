import { Turbo } from "@hotwired/turbo-rails";

const CONFIRM_MODAL_ID = "appConfirmModal";
const CONFIRM_MODAL_OPEN_CLASS = "app-confirm-modal--open";
const BODY_MODAL_OPEN_CLASS = "app-modal-open";

function escapeHtml(value) {
  const element = document.createElement("div");
  element.textContent = value;
  return element.innerHTML;
}

function isDeleteAction(element) {
  return element?.dataset?.turboMethod === "delete" ||
    element?.getAttribute("method")?.toLowerCase() === "delete" ||
    element?.querySelector("input[name='_method']")?.value === "delete";
}

function confirmTitle(element) {
  return element?.dataset?.turboConfirmTitle ||
    (isDeleteAction(element) ? "Confirmar exclusao" : "Confirmar acao");
}

function confirmButtonLabel(element) {
  return element?.dataset?.turboConfirmButton ||
    (isDeleteAction(element) ? "Excluir" : "Confirmar");
}

// Cria o modal de confirmacao sem depender do componente Modal do Bootstrap.
function buildConfirmModal(message, element) {
  document.getElementById(CONFIRM_MODAL_ID)?.remove();

  const modal = document.createElement("div");
  modal.id = CONFIRM_MODAL_ID;
  modal.className = "app-confirm-modal";
  modal.setAttribute("aria-hidden", "true");
  modal.innerHTML = `
    <div class="app-confirm-modal__backdrop" data-confirm-cancel></div>
    <div class="app-confirm-modal__dialog" role="dialog" aria-modal="true">
      <div class="app-confirm-modal__content">
        <div class="app-confirm-modal__header">
          <span class="app-confirm-modal__icon material-symbols-rounded">warning</span>
          <div>
            <h5 class="app-confirm-modal__title">${escapeHtml(confirmTitle(element))}</h5>
            <p class="app-confirm-modal__message">${escapeHtml(message)}</p>
          </div>
        </div>
        <div class="app-confirm-modal__actions">
          <button type="button" class="app-btn app-confirm-modal__cancel" data-confirm-cancel>Cancelar</button>
          <button type="button" class="app-btn app-confirm-modal__confirm" data-confirm-accept>${escapeHtml(confirmButtonLabel(element))}</button>
        </div>
      </div>
    </div>
  `;

  document.body.appendChild(modal);
  return modal;
}

function openConfirmModal(modalElement) {
  modalElement.classList.add(CONFIRM_MODAL_OPEN_CLASS);
  modalElement.setAttribute("aria-hidden", "false");
  document.body.classList.add(BODY_MODAL_OPEN_CLASS);
}

function closeConfirmModal(modalElement) {
  modalElement.classList.remove(CONFIRM_MODAL_OPEN_CLASS);
  modalElement.setAttribute("aria-hidden", "true");
  document.body.classList.remove(BODY_MODAL_OPEN_CLASS);
  modalElement.remove();
}

function showConfirmDialog(message, element) {
  return new Promise((resolve) => {
    const modalElement = buildConfirmModal(message, element);
    let settled = false;

    const settle = (result) => {
      if (settled) return;

      settled = true;
      resolve(result);
      closeConfirmModal(modalElement);
    };

    const handleKeydown = (event) => {
      if (event.key === "Escape") {
        settle(false);
      }
    };

    modalElement.querySelectorAll("[data-confirm-cancel]").forEach((cancelElement) => {
      cancelElement.addEventListener("click", () => settle(false));
    });

    modalElement.querySelector("[data-confirm-accept]")?.addEventListener("click", () => settle(true));
    document.addEventListener("keydown", handleKeydown, { once: true });

    modalElement.addEventListener("app-confirm-modal:close", () => {
      document.removeEventListener("keydown", handleKeydown);
    }, { once: true });

    openConfirmModal(modalElement);
  });
}

Turbo.setConfirmMethod(showConfirmDialog);
