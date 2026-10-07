function initializeHealthReviewForm() {
  document.querySelectorAll("[data-health-review-form]").forEach((form) => {
    if (form.dataset.healthReviewFormBound === "true") return;

    form.dataset.healthReviewFormBound = "true";

    const kindSelect = form.querySelector("[data-health-review-kind]");
    const dailyField = form.querySelector("[data-health-review-daily-field]");
    const weeklyField = form.querySelector("[data-health-review-weekly-field]");

    if (!kindSelect) return;

    const toggleFields = () => {
      const daily = kindSelect.value === "daily";

      if (dailyField) dailyField.hidden = !daily;
      if (weeklyField) weeklyField.hidden = daily;
      dailyField?.querySelector("input")?.toggleAttribute("required", daily);
      weeklyField?.querySelector("select")?.toggleAttribute("required", !daily);

      form.querySelectorAll("[data-health-review-question]").forEach((label) => {
        label.textContent = daily ? label.dataset.daily : label.dataset.weekly;
      });
      const submit = form.closest("form").querySelector("[data-health-review-submit]");
      if (submit) submit.value = daily ? "Salvar perguntas do dia" : "Salvar perguntas da semana";
    };

    kindSelect.addEventListener("change", toggleFields);
    toggleFields();
  });
}

document.addEventListener("turbo:load", initializeHealthReviewForm);
document.addEventListener("turbo:render", initializeHealthReviewForm);
