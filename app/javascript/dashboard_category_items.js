function initializeDashboardCategoryItems() {
  document.querySelectorAll(".dashboard-category-item__copy").forEach((toggle) => {
    if (toggle.dataset.bound === "true") return;

    toggle.dataset.bound = "true";
    toggle.addEventListener("click", () => {
      const item = toggle.closest(".dashboard-category-item");
      if (!item) return;

      const shouldOpen = !item.classList.contains("is-open");

      document.querySelectorAll(".dashboard-category-item.is-open").forEach((openItem) => {
        if (openItem === item) return;

        openItem.classList.remove("is-open");
        openItem.querySelector(".dashboard-category-item__copy")?.setAttribute("aria-expanded", "false");
      });

      item.classList.toggle("is-open", shouldOpen);
      toggle.setAttribute("aria-expanded", shouldOpen ? "true" : "false");
    });
  });
}

document.addEventListener("turbo:load", initializeDashboardCategoryItems);
document.addEventListener("turbo:frame-load", initializeDashboardCategoryItems);
