import { initializeDatepicker } from "./date_picker";
import { initializeFormUtils } from "./utils";

function parseBrazilianDate(value) {
  const match = value?.match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
  if (!match) return null;

  return new Date(Number(match[3]), Number(match[2]) - 1, Number(match[1]));
}

function formatBrazilianDate(date) {
  return [
    String(date.getDate()).padStart(2, "0"),
    String(date.getMonth() + 1).padStart(2, "0"),
    date.getFullYear()
  ].join("/");
}

function dateWithDay(year, monthIndex, day) {
  const lastDay = new Date(year, monthIndex + 1, 0).getDate();

  return new Date(year, monthIndex, Math.min(day, lastDay));
}

function cardBalanceDate(purchaseDate, cardOption) {
  const dueDay = Number(cardOption?.dataset.dueDay);
  const closingDay = Number(cardOption?.dataset.closingDay);

  if (!dueDay || !closingDay) return purchaseDate;

  const closingMonthOffset = purchaseDate.getDate() <= closingDay ? 0 : 1;
  const closingDate = dateWithDay(
    purchaseDate.getFullYear(),
    purchaseDate.getMonth() + closingMonthOffset,
    closingDay
  );
  const dueMonthOffset = dueDay > closingDay ? 0 : 1;

  return dateWithDay(closingDate.getFullYear(), closingDate.getMonth() + dueMonthOffset, dueDay);
}

function defaultBalanceDate(row) {
  const purchaseDate = parseBrazilianDate(row.querySelector("[data-expense-date-input]")?.value);
  if (!purchaseDate) return null;

  const paymentMethod = row.querySelector("[data-payment-method-select]")?.value;

  if (paymentMethod === "credito_a_vista" || paymentMethod === "credito_parcelado") {
    const cardSelect = row.querySelector("[data-card-select]");
    return cardBalanceDate(purchaseDate, cardSelect?.selectedOptions[0]);
  }

  return purchaseDate;
}

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
      const dateInput = row.querySelector("[data-expense-date-input]");
      const balanceInput = row.querySelector("[data-expense-balance-input]");
      const cardSelect = row.querySelector("[data-card-select]");

      const refreshBalanceDate = () => {
        if (!balanceInput) return;
        if (balanceInput.value && balanceInput.dataset.balanceAutoFilled === "false") return;

        const balanceDate = defaultBalanceDate(row);
        if (!balanceDate) return;

        balanceInput.dataset.updatingBalance = "true";
        balanceInput.value = formatBrazilianDate(balanceDate);
        balanceInput.dataset.balanceAutoFilled = "true";
        balanceInput.dispatchEvent(new Event("change", { bubbles: true }));
        delete balanceInput.dataset.updatingBalance;
      };

      if (paymentSelect && installmentsSection && paymentSelect.dataset.bound !== "true") {
        const toggleInstallments = () => {
          installmentsSection.classList.toggle("is-visible", paymentSelect.value === "credito_parcelado");
          refreshBalanceDate();
        };

        paymentSelect.dataset.bound = "true";
        paymentSelect.addEventListener("change", toggleInstallments);
        toggleInstallments();
      }

      if (dateInput && dateInput.dataset.balanceBound !== "true") {
        dateInput.dataset.balanceBound = "true";
        dateInput.addEventListener("change", refreshBalanceDate);
        dateInput.addEventListener("input", refreshBalanceDate);
      }

      if (cardSelect && cardSelect.dataset.balanceBound !== "true") {
        cardSelect.dataset.balanceBound = "true";
        cardSelect.addEventListener("change", refreshBalanceDate);
      }

      if (balanceInput && balanceInput.dataset.manualBound !== "true") {
        balanceInput.dataset.manualBound = "true";
        const markBalanceDateAsManual = () => {
          if (balanceInput.dataset.updatingBalance === "true") return;

          balanceInput.dataset.balanceAutoFilled = "false";
        };

        balanceInput.addEventListener("input", markBalanceDateAsManual);
        balanceInput.addEventListener("change", markBalanceDateAsManual);
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
