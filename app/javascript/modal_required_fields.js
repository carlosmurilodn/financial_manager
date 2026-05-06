const REQUIRED_SELECTOR = "input:not([type='hidden']):not([disabled]), select:not([disabled]), textarea:not([disabled])";
const CREDIT_PAYMENT_METHODS = ["credito_a_vista", "credito_parcelado"];

function closestField(input) {
  return input.closest(".expense-modal-field, .app-goal-resource-form__field, .invoice-import-field, .app-form-field, .col-md-3, .col-md-4, .col-md-5, .col-md-6, .col-md-7, .col-md-8, .col-md-9, .mb-3");
}

function paymentMethodValue(input) {
  const scope = input.closest("[data-expense-row], form") || document;
  return scope.querySelector("[data-payment-method-select], #payment_method_select, [name$='[payment_method]']")?.value;
}

function shouldValidateInput(input) {
  return input.matches(REQUIRED_SELECTOR) && !input.closest("template");
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

function isConditionallyRequired(input) {
  return input.dataset.requiredWhenCredit === "true" || input.dataset.requiredWhenInstallments === "true";
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

function feedbackIdFor(input) {
  if (!input.id) {
    input.id = `required-field-${crypto.randomUUID()}`;
  }

  return `${input.id}-required-feedback`;
}

function removeRequiredFeedback(input) {
  if (input.dataset.requiredFeedbackActive !== "true") return;

  const field = closestField(input);
  const feedbackId = input.dataset.requiredFeedbackId;

  if (feedbackId) {
    document.getElementById(feedbackId)?.remove();
  }

  delete input.dataset.requiredFeedbackActive;
  delete input.dataset.requiredFeedbackId;
  field?.classList.remove("has-required-error");
  input.removeAttribute("aria-describedby");
}

function showRequiredFeedback(input) {
  const field = closestField(input) || input.parentElement;
  if (!field) return;

  const feedbackId = feedbackIdFor(input);
  let feedback = document.getElementById(feedbackId);

  if (!feedback) {
    feedback = document.createElement("div");
    feedback.id = feedbackId;
    feedback.className = "app-required-feedback";
    field.appendChild(feedback);
  }

  feedback.textContent = invalidMessage(input);
  input.dataset.requiredFeedbackActive = "true";
  input.dataset.requiredFeedbackId = feedbackId;
  input.setAttribute("aria-describedby", feedbackId);
}

function setInvalid(input, invalid, { show = true } = {}) {
  const field = closestField(input);
  const visibleInvalid = invalid && show;

  input.classList.toggle("is-invalid", visibleInvalid);
  input.setAttribute("aria-invalid", visibleInvalid ? "true" : "false");
  field?.classList.toggle("has-required-error", visibleInvalid);

  if (visibleInvalid) {
    showRequiredFeedback(input);
  } else {
    removeRequiredFeedback(input);
  }
}

function validateInput(input, options = {}) {
  const invalid = isInvalid(input);
  setInvalid(input, invalid, options);
  return !invalid;
}

function validateForm(form) {
  form.dataset.requiredSubmitAttempted = "true";

  const inputs = [...form.querySelectorAll(REQUIRED_SELECTOR)].filter(shouldValidateInput);
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
  if (!shouldValidateInput(event.target)) return;

  const form = event.target.closest("form");
  const show = !isConditionallyRequired(event.target) ||
    form?.dataset.requiredSubmitAttempted === "true" ||
    event.target.dataset.requiredFeedbackActive === "true";

  validateInput(event.target, { show });
});

document.addEventListener("change", (event) => {
  if (!shouldValidateInput(event.target)) return;

  const form = event.target.closest("form");
  if (!form) {
    validateInput(event.target);
    return;
  }

  const show = !isConditionallyRequired(event.target) ||
    form.dataset.requiredSubmitAttempted === "true" ||
    event.target.dataset.requiredFeedbackActive === "true";

  validateInput(event.target, { show });

  if (event.target.matches("[data-payment-method-select], #payment_method_select, [name$='[payment_method]']")) {
    form.querySelectorAll("[data-required-when-credit='true'], [data-required-when-installments='true']").forEach((input) => {
      if (!shouldValidateInput(input)) return;

      validateInput(input, {
        show: form.dataset.requiredSubmitAttempted === "true" || input.dataset.requiredFeedbackActive === "true"
      });
    });
  }
});

document.addEventListener("turbo:load", () => initializeModalRequiredFields());
document.addEventListener("turbo:render", () => initializeModalRequiredFields());
