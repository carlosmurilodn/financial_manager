const REQUIRED_SELECTOR = "input, select, textarea";
const CREDIT_PAYMENT_METHODS = ["credito_a_vista", "credito_parcelado"];

function closestField(input) {
  return input.closest(".expense-modal-field, .app-goal-resource-form__field, .col-md-3, .col-md-4, .col-md-5, .col-md-6, .col-md-7, .col-md-8, .col-md-9, .mb-3");
}

function paymentMethodValue(input) {
  const scope = input.closest("[data-expense-row], form") || document;
  return scope.querySelector("[data-payment-method-select], #payment_method_select, [name$='[payment_method]']")?.value;
}

function isRequired(input) {
  if (input.dataset.requiredWhenCredit === "true") {
    return CREDIT_PAYMENT_METHODS.includes(paymentMethodValue(input));
  }

  if (input.dataset.requiredWhenInstallments === "true") {
    return paymentMethodValue(input) === "credito_parcelado";
  }

  return input.required;
}

function currencyValue(input) {
  return Number(input.value.replace(/\D/g, ""));
}

function invalidMessage(input) {
  if (input.dataset.requiredCurrency === "true" && currencyValue(input) <= 0) {
    return "Informe um valor maior que zero.";
  }

  return input.dataset.requiredMessage || "Campo obrigatorio.";
}

function isEmpty(input) {
  if (input.type === "checkbox" || input.type === "radio") return !input.checked;
  return input.value.trim() === "";
}

function isInvalid(input) {
  if (!isRequired(input)) return false;
  if (input.dataset.requiredCurrency === "true") return currencyValue(input) <= 0;
  return isEmpty(input);
}

function feedbackFor(input) {
  const field = closestField(input);
  if (!field) return null;

  let feedback = field.querySelector(":scope > .invalid-feedback");
  if (!feedback) {
    feedback = document.createElement("div");
    feedback.className = "invalid-feedback";
    field.appendChild(feedback);
  }

  return feedback;
}

function setInvalid(input, invalid) {
  const field = closestField(input);
  const feedback = feedbackFor(input);

  input.classList.toggle("is-invalid", invalid);
  input.setAttribute("aria-invalid", invalid ? "true" : "false");
  field?.classList.toggle("has-required-error", invalid);

  if (feedback) {
    feedback.textContent = invalid ? invalidMessage(input) : "";
    feedback.classList.toggle("d-block", invalid);
  }
}

function validateInput(input) {
  const invalid = isInvalid(input);
  setInvalid(input, invalid);
  return !invalid;
}

function validateForm(form) {
  const inputs = [...form.querySelectorAll(REQUIRED_SELECTOR)];
  const invalidInputs = inputs.filter((input) => !validateInput(input));
  const firstInvalid = invalidInputs[0];

  if (firstInvalid) {
    firstInvalid.scrollIntoView({ block: "center", behavior: "smooth" });
    firstInvalid.focus({ preventScroll: true });
  }

  return invalidInputs.length === 0;
}

export function initializeModalRequiredFields(scope = document) {
  scope.querySelectorAll("form").forEach((form) => {
    if (form.dataset.requiredFieldsBound === "true") return;

    form.dataset.requiredFieldsBound = "true";
    form.noValidate = true;

    form.addEventListener("submit", (event) => {
      if (validateForm(form)) return;

      event.preventDefault();
      event.stopImmediatePropagation();
    }, true);
  });
}

document.addEventListener("input", (event) => {
  if (!event.target.matches(REQUIRED_SELECTOR)) return;
  validateInput(event.target);
});

document.addEventListener("change", (event) => {
  if (!event.target.matches(REQUIRED_SELECTOR)) return;

  const form = event.target.closest("form");
  if (!form) {
    validateInput(event.target);
    return;
  }

  validateInput(event.target);

  if (event.target.matches("[data-payment-method-select], #payment_method_select, [name$='[payment_method]']")) {
    form.querySelectorAll("[data-required-when-credit='true'], [data-required-when-installments='true']").forEach(validateInput);
  }
});

document.addEventListener("turbo:load", () => initializeModalRequiredFields());
document.addEventListener("turbo:render", () => initializeModalRequiredFields());
