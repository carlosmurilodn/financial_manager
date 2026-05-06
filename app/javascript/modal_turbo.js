import { Tooltip } from "bootstrap";
import { initializeFormUtils } from "./utils";
import { initializeDatepicker } from "./date_picker";
import { initializeExpenseForm } from "./expense_form";
import { initializeFinancialGoalForm } from "./financial_goal_form";
import { initializeModalRequiredFields } from "./modal_required_fields";

const modalOpenClass = "app-modal--open";
const bodyOpenClass = "app-modal-open";

function getModal() {
  return document.getElementById("appModal");
}

function getModalBody() {
  return document.getElementById("app-modal-body");
}

function initializeInvoiceFilePreview(scope) {
  const fileInput = scope.querySelector("[data-invoice-file-input]");
  const previewButton = scope.querySelector("[data-invoice-file-preview]");

  if (!fileInput || !previewButton || previewButton.dataset.bound === "true") return;

  let fileUrl = null;

  const revokeFileUrl = () => {
    if (!fileUrl) return;

    URL.revokeObjectURL(fileUrl);
    fileUrl = null;
  };

  const refreshButtonState = () => {
    revokeFileUrl();
    previewButton.disabled = fileInput.files.length === 0;
  };

  previewButton.dataset.bound = "true";
  previewButton.disabled = fileInput.files.length === 0;

  previewButton.addEventListener("click", () => {
    const file = fileInput.files[0];
    if (!file) return;

    revokeFileUrl();
    fileUrl = URL.createObjectURL(file);
    window.open(fileUrl, "_blank", "noopener");
  });

  fileInput.addEventListener("change", refreshButtonState);

  scope.addEventListener("invoice-file-preview:cleanup", revokeFileUrl, { once: true });
}

function cleanupModalBody(modalBody) {
  modalBody.dispatchEvent(new CustomEvent("invoice-file-preview:cleanup"));

  modalBody.querySelectorAll("[data-bs-toggle='tooltip']").forEach((element) => {
    Tooltip.getInstance(element)?.dispose();
  });

  modalBody.innerHTML = "";
}

function hideTurboModal() {
  const modalElement = getModal();
  const modalBody = getModalBody();

  if (!modalElement) return;

  modalElement.dispatchEvent(new CustomEvent("app-modal:before-close"));
  modalElement.classList.remove(modalOpenClass);
  modalElement.setAttribute("aria-hidden", "true");
  document.body.classList.remove(bodyOpenClass);

  if (modalBody) cleanupModalBody(modalBody);
}

function showTurboModal() {
  const modalElement = getModal();

  if (!modalElement) return;

  modalElement.classList.add(modalOpenClass);
  modalElement.setAttribute("aria-hidden", "false");
  document.body.classList.add(bodyOpenClass);
}

function bindModalCloseEvents() {
  const modalElement = getModal();

  if (!modalElement || modalElement.dataset.modalBound === "true") return;

  modalElement.dataset.modalBound = "true";

  modalElement.addEventListener("click", (event) => {
    if (event.target.dataset.modalBackdrop === "true") {
      hideTurboModal();
    }
  });
}

document.addEventListener("turbo:load", bindModalCloseEvents);

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    hideTurboModal();
  }
});

document.addEventListener("click", (event) => {
  const closeTrigger = event.target.closest("[data-close-modal]");

  if (closeTrigger) {
    hideTurboModal();
  }
});

document.addEventListener("turbo:before-stream-render", (event) => {
  const stream = event.target;
  if (stream?.target !== "modal") return;
  if (!["update", "replace"].includes(stream.action)) return;
  if (stream.templateContent?.textContent.trim() !== "") return;

  hideTurboModal();
});

document.addEventListener("turbo:frame-load", (event) => {
  if (event.target.id !== "modal") return;

  const modalFrame = event.target;
  const modalBody = getModalBody();
  const modalElement = getModal();

  if (!modalBody || !modalElement) return;

  const frameContent = modalFrame.innerHTML.trim();

  // Se o backend retornou turbo_stream.replace("modal", ""),
  // o frame vem vazio. Aí sim a modal deve fechar.
  if (frameContent === "") {
    hideTurboModal();

    window.location.reload();
    return;
  }

  let activeModalRequestController = null;
  let modalRequestAborted = false;

  modalBody.innerHTML = modalFrame.innerHTML;

  modalBody.querySelectorAll("[data-expense-form-bound]").forEach((form) => {
    delete form.dataset.expenseFormBound;
  });

  modalElement.classList.toggle("app-modal--lg", !!modalBody.querySelector("[data-modal-size='xl'], [data-modal-size='wide']"));
  showTurboModal();

  initializeFormUtils();
  initializeModalRequiredFields(modalBody);
  initializeDatepicker();
  initializeExpenseForm();
  initializeFinancialGoalForm(modalBody);
  initializeInvoiceFilePreview(modalBody);

  modalBody.querySelectorAll("[data-bs-toggle='tooltip']").forEach((element) => {
    Tooltip.getOrCreateInstance(element);
  });

  const paymentSelect = modalBody.querySelector("#payment_method_select");
  const parcelSection = modalBody.querySelector("#parcelamento_section");

  if (paymentSelect && parcelSection) {
    const toggleParcelSection = () => {
      parcelSection.style.display =
        paymentSelect.value === "credito_parcelado" ? "flex" : "none";
    };

    toggleParcelSection();
    paymentSelect.addEventListener("change", toggleParcelSection);
  }

  modalBody.querySelectorAll("form").forEach((form) => {
    const resetModalRequestState = () => {
      activeModalRequestController = null;
      modalRequestAborted = false;
      modalBody.querySelector("[data-invoice-loading]")?.classList.remove("is-visible");
      form.querySelector("[type='submit']")?.removeAttribute("disabled");
    };

    form.addEventListener("turbo:before-fetch-request", (e) => {
      if (form.dataset.stayModal !== "true") return;

      activeModalRequestController = new AbortController();
      modalRequestAborted = false;
      e.detail.fetchOptions.signal = activeModalRequestController.signal;
    });

    form.addEventListener("turbo:submit-start", () => {
      if (form.dataset.stayModal !== "true") return;

      const loadingOverlay = modalBody.querySelector("[data-invoice-loading]");
      const submitButton = form.querySelector("[type='submit']");

      loadingOverlay?.classList.add("is-visible");
      submitButton?.setAttribute("disabled", "disabled");
    });

    form.addEventListener("turbo:submit-end", (e) => {
      const { success } = e.detail;

      resetModalRequestState();

      if (success && form.dataset.stayModal !== "true") {
        hideTurboModal();
        window.location.reload();
      }
    });

    form.addEventListener("turbo:fetch-request-error", (e) => {
      if (!modalRequestAborted) return;

      e.preventDefault();
      resetModalRequestState();
    });
  });

  modalElement.addEventListener(
    "app-modal:before-close",
    () => {
      if (activeModalRequestController) {
        modalRequestAborted = true;
        activeModalRequestController.abort();
        activeModalRequestController = null;
      }

      modalBody.querySelector("[data-invoice-loading]")?.classList.remove("is-visible");
      modalBody.querySelector("form [type='submit']")?.removeAttribute("disabled");
    },
    { once: true }
  );
});

window.AppModal = {
  open: showTurboModal,
  close: hideTurboModal
};
