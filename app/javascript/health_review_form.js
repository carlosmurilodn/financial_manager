function initializeHealthReviewForm() {
  document.querySelectorAll("[data-health-review-form]").forEach((form) => {
    if (form.dataset.healthReviewFormBound === "true") return;

    form.dataset.healthReviewFormBound = "true";

    const kindSelect = form.querySelector("[data-health-review-kind]");
    const dailyField = form.querySelector("[data-health-review-daily-field]");
    const weeklyField = form.querySelector("[data-health-review-weekly-field]");

    if (!kindSelect || !dailyField || !weeklyField) return;

    const toggleFields = () => {
      const daily = kindSelect.value === "daily";

      dailyField.hidden = !daily;
      weeklyField.hidden = daily;
      dailyField.querySelector("input")?.toggleAttribute("required", daily);
      weeklyField.querySelector("select")?.toggleAttribute("required", !daily);
    };

    kindSelect.addEventListener("change", toggleFields);
    toggleFields();
  });
}

document.addEventListener("turbo:load", initializeHealthReviewForm);
document.addEventListener("turbo:render", initializeHealthReviewForm);
