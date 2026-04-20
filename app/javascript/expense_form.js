import { initializeDatepicker } from "./date_picker";
import { initializeFormUtils } from "./utils";

export function initializeExpenseForm() {
  document.querySelectorAll("[data-expense-form]").forEach((form) => {
    if (form.dataset.expenseFormBound === "true") return;

    form.dataset.expenseFormBound = "true";

    const rowsContainer = form.querySelector("[data-expense-rows]");
    const template = form.querySelector("[data-expense-row-template]");
    const addButton = form.querySelector("[data-add-expense-row]");

    if (!rowsContainer || !template || !addButton) return;

    const updateRemoveButtons = () => {
      const rows = rowsContainer.querySelectorAll("[data-expense-row]");

      rows.forEach((row) => {
        row.querySelector("[data-remove-expense-row]")?.classList.toggle("is-hidden", rows.length === 1);
      });
    };

    const setupRow = (row) => {
      const paymentSelect = row.querySelector("[data-payment-method-select]");
      const installmentsSection = row.querySelector("[data-installments-section]");
      const removeButton = row.querySelector("[data-remove-expense-row]");

      if (paymentSelect && installmentsSection && paymentSelect.dataset.bound !== "true") {
        const toggleInstallments = () => {
          installmentsSection.classList.toggle("is-visible", paymentSelect.value === "credito_parcelado");
        };

        paymentSelect.dataset.bound = "true";
        paymentSelect.addEventListener("change", toggleInstallments);
        toggleInstallments();
      }

      if (removeButton && removeButton.dataset.bound !== "true") {
        removeButton.dataset.bound = "true";
        removeButton.addEventListener("click", () => {
          row.remove();
          updateRemoveButtons();
        });
      }
    };

    rowsContainer.querySelectorAll("[data-expense-row]").forEach(setupRow);
    updateRemoveButtons();

    addButton.addEventListener("click", () => {
      const index = Date.now().toString();
      const wrapper = document.createElement("div");

      wrapper.innerHTML = template.innerHTML.replace(/NEW_RECORD/g, index).trim();
      const row = wrapper.firstElementChild;

      rowsContainer.appendChild(row);
      setupRow(row);
      updateRemoveButtons();
      initializeFormUtils();
      initializeDatepicker();
    });
  });
}

document.addEventListener("turbo:load", initializeExpenseForm);
