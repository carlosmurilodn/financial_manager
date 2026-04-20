import { initializeFormUtils } from "./utils";
import { initializeDatepicker } from "./date_picker";
import { initializeExpenseForm } from "./expense_form";

document.addEventListener("turbo:frame-load", (event) => {
  if (event.target.id === "modal") {
    const modalBody = document.getElementById("modal-body");
    const modalElement = document.getElementById("turboModal");
    const modalDialog = modalElement.querySelector(".modal-dialog");

    modalBody.innerHTML = event.target.innerHTML;
    modalBody.querySelectorAll("[data-expense-form-bound]").forEach((form) => {
      delete form.dataset.expenseFormBound;
    });
    modalDialog.classList.toggle("modal-xl", !!modalBody.querySelector("[data-modal-size='xl']"));
    modalDialog.classList.toggle("modal-wide", !!modalBody.querySelector("[data-modal-size='wide']"));

    const modal = new bootstrap.Modal(modalElement);
    modal.show();

    initializeFormUtils();
    initializeDatepicker();
    initializeExpenseForm();

    // ---------- TOGGLE PARCELAMENTO ----------
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

    // ---------- SUBMIT FORMULARIO ----------
    const form = modalBody.querySelector("form");
    if (form) {
      form.addEventListener("turbo:submit-start", () => {
        if (form.dataset.stayModal !== "true") return;

        const loadingOverlay = modalBody.querySelector("[data-invoice-loading]");
        const submitButton = form.querySelector("[type='submit']");

        loadingOverlay?.classList.add("is-visible");
        submitButton?.setAttribute("disabled", "disabled");
      });

      form.addEventListener("turbo:submit-end", (e) => {
        const { success } = e.detail;

        modalBody.querySelector("[data-invoice-loading]")?.classList.remove("is-visible");
        form.querySelector("[type='submit']")?.removeAttribute("disabled");

        if (success && form.dataset.stayModal !== "true") {
          modal.hide();                 // fecha modal
          window.location.reload();     // recarrega página inteira
        }
      });
    }

    // ---------- LIMPEZA AO FECHAR ----------
    modalElement.addEventListener(
      "hidden.bs.modal",
      () => {
        modalBody.innerHTML = "";
        const backdrop = document.querySelector(".modal-backdrop");
        if (backdrop) backdrop.remove();
        document.body.classList.remove("modal-open");
        document.body.style.overflow = "";
        document.body.style.paddingRight = "";
      },
      { once: true }
    );
  }
});
