// app/javascript/modal.js
import { initializeFormUtils } from "./utils";
import { initializeDatepicker } from "./date_picker";

document.addEventListener("turbo:frame-load", (event) => {
  if (event.target.id === "modal") {
    const modalBody = document.getElementById("modal-body");
    const modalElement = document.getElementById("turboModal");

    modalBody.innerHTML = event.target.innerHTML;

    const modal = new bootstrap.Modal(modalElement);
    modal.show();

    // Inicializa utils e datepicker
    initializeFormUtils();
    initializeDatepicker();

    // ---------- TOGGLE PARCELAMENTO AQUI ----------
    const paymentSelect = modalBody.querySelector("#payment_method_select");
    const parcelSection = modalBody.querySelector("#parcelamento_section");
    if (paymentSelect && parcelSection) {
      const toggleParcelSection = () => {
        parcelSection.style.display =
          paymentSelect.value === "credito_parcelado" ? "flex" : "none";
      };

      // Estado inicial
      toggleParcelSection();

      // Atualiza dinamicamente
      paymentSelect.addEventListener("change", toggleParcelSection);
    }
    // ----------------------------------------------

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
