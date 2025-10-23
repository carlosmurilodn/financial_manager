import { initializeFormUtils } from "./utils";
import { initializeDatepicker } from "./date_picker";

document.addEventListener("turbo:frame-load", (event) => {
  if (event.target.id === "modal") {
    const modalBody = document.getElementById("modal-body");
    const modalElement = document.getElementById("turboModal");

    modalBody.innerHTML = event.target.innerHTML;

    const modal = new bootstrap.Modal(modalElement);
    modal.show();

    initializeFormUtils();
    initializeDatepicker();

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
      form.addEventListener("turbo:submit-end", (e) => {
        const { success } = e.detail;

        if (success) {
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
