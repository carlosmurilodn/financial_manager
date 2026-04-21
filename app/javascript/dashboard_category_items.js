function initializeDashboardCategoryItems() {
  document.querySelectorAll(".dashboard-category-item__copy").forEach((toggle) => {
    if (toggle.dataset.bound === "true") return;

    toggle.dataset.bound = "true";
    toggle.addEventListener("click", () => {
      const item = toggle.closest(".dashboard-category-item");
      if (!item) return;

      const shouldOpen = !item.classList.contains("is-open");

      document.querySelectorAll(".dashboard-category-item.is-open, .dashboard-card-balance.is-open").forEach((openItem) => {
        if (openItem === item) return;

        openItem.classList.remove("is-open");
        openItem.querySelector(".dashboard-category-item__copy, .dashboard-card-balance__toggle")?.setAttribute("aria-expanded", "false");
      });

      item.classList.toggle("is-open", shouldOpen);
      toggle.setAttribute("aria-expanded", shouldOpen ? "true" : "false");
    });
  });

  document.querySelectorAll(".dashboard-card-balance--clickable").forEach((card) => {
    if (card.dataset.bound === "true") return;

    card.dataset.bound = "true";
    card.addEventListener("click", (event) => {
      if (event.target.closest(".dashboard-card-balance__details")) return;

      const toggle = card.querySelector(".dashboard-card-balance__toggle");
      const shouldOpen = !card.classList.contains("is-open");

      document.querySelectorAll(".dashboard-category-item.is-open, .dashboard-card-balance.is-open").forEach((openItem) => {
        if (openItem === card) return;

        openItem.classList.remove("is-open");
        openItem.querySelector(".dashboard-category-item__copy, .dashboard-card-balance__toggle")?.setAttribute("aria-expanded", "false");
      });

      card.classList.toggle("is-open", shouldOpen);
      toggle?.setAttribute("aria-expanded", shouldOpen ? "true" : "false");
    });
  });
}

document.addEventListener("turbo:load", initializeDashboardCategoryItems);
document.addEventListener("turbo:frame-load", initializeDashboardCategoryItems);
