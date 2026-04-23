import { initializeFormUtils } from "./utils";

export function initializeFinancialGoalForm(scope = document) {
  scope.querySelectorAll("[data-financial-goal-form]").forEach((form) => {
    if (form.dataset.financialGoalFormBound === "true") return;

    form.dataset.financialGoalFormBound = "true";

    const rowsContainer = form.querySelector("[data-goal-resource-rows]");
    const template = form.querySelector("[data-goal-resource-template]");
    const addButton = form.querySelector("[data-add-goal-resource-row]");

    if (!rowsContainer || !template || !addButton) return;

    rowsContainer.addEventListener("click", (event) => {
      const removeButton = event.target.closest("[data-remove-goal-resource-row]");
      if (!removeButton) return;

      const row = removeButton.closest("[data-goal-resource-row]");
      const persistedId = row?.querySelector("input[name$='[id]']")?.value;
      const destroyInput = row?.querySelector("[data-goal-resource-destroy]");

      if (persistedId && destroyInput) {
        destroyInput.value = "1";
        row.hidden = true;
        return;
      }

      row?.remove();
    });

    addButton.addEventListener("click", () => {
      const wrapper = document.createElement("div");
      const index = Date.now().toString();

      wrapper.innerHTML = template.innerHTML.replace(/NEW_RECORD/g, index).trim();
      rowsContainer.appendChild(wrapper.firstElementChild);
      initializeFormUtils();
    });
  });
}

document.addEventListener("turbo:load", () => initializeFinancialGoalForm());
