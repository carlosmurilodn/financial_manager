import { initializeDatepicker } from "./date_picker";
import { initializeFormUtils } from "./utils";

export function initializeIncomeForm() {
  document.querySelectorAll("[data-income-form]").forEach((form) => {
    if (form.dataset.incomeFormBound === "true") return;

    form.dataset.incomeFormBound = "true";

    const rowsContainer = form.querySelector("[data-income-rows]");
    const template = form.querySelector("[data-income-row-template]");
    const addButton = form.querySelector("[data-add-income-row]");

    if (!rowsContainer || !template || !addButton) return;

    const updateRemoveButtons = () => {
      const rows = rowsContainer.querySelectorAll("[data-income-row]");

      rows.forEach((row) => {
        row.querySelector("[data-remove-income-row]")?.classList.toggle("is-hidden", rows.length === 1);
      });
    };

    const setupRow = (row) => {
      const removeButton = row.querySelector("[data-remove-income-row]");
      if (!removeButton || removeButton.dataset.bound === "true") return;

      removeButton.dataset.bound = "true";
      removeButton.addEventListener("click", () => {
        row.remove();
        updateRemoveButtons();
      });
    };

    rowsContainer.querySelectorAll("[data-income-row]").forEach(setupRow);
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

document.addEventListener("turbo:load", initializeIncomeForm);
