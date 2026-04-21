import { Turbo } from "@hotwired/turbo-rails";

const CONFIRM_MODAL_ID = "appConfirmModal";

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

function buildConfirmModal(message, element) {
  document.getElementById(CONFIRM_MODAL_ID)?.remove();

  const modal = document.createElement("div");
  modal.id = CONFIRM_MODAL_ID;
  modal.className = "modal fade app-confirm-modal";
  modal.tabIndex = -1;
  modal.setAttribute("aria-hidden", "true");
  modal.innerHTML = `
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content app-confirm-modal__content">
        <div class="app-confirm-modal__header">
          <span class="app-confirm-modal__icon material-symbols-rounded">warning</span>
          <div>
            <h5 class="app-confirm-modal__title">${escapeHtml(confirmTitle(element))}</h5>
            <p class="app-confirm-modal__message">${escapeHtml(message)}</p>
          </div>
        </div>
        <div class="app-confirm-modal__actions">
          <button type="button" class="btn app-confirm-modal__cancel" data-confirm-cancel>Cancelar</button>
          <button type="button" class="btn app-confirm-modal__confirm" data-confirm-accept>${escapeHtml(confirmButtonLabel(element))}</button>
        </div>
      </div>
    </div>
  `;

  document.body.appendChild(modal);
  return modal;
}

function showConfirmDialog(message, element) {
  return new Promise((resolve) => {
    const modalElement = buildConfirmModal(message, element);
    const modal = new bootstrap.Modal(modalElement, { backdrop: "static", keyboard: true });
    let settled = false;

    const settle = (result) => {
      if (settled) return;

      settled = true;
      resolve(result);
      modal.hide();
    };

    modalElement.querySelector("[data-confirm-accept]")?.addEventListener("click", () => settle(true));
    modalElement.querySelector("[data-confirm-cancel]")?.addEventListener("click", () => settle(false));

    modalElement.addEventListener("hidden.bs.modal", () => {
      if (!settled) resolve(false);
      modal.dispose();
      modalElement.remove();
    }, { once: true });

    modal.show();
  });
}

Turbo.setConfirmMethod(showConfirmDialog);
