function refreshColorBadge(select) {
  const field = select.closest(".app-color-select-field");
  const badge = field?.querySelector(".app-color-name-badge");
  const selectedOption = select.options[select.selectedIndex];

  if (!badge || !selectedOption) return;

  badge.textContent = selectedOption.textContent.trim();
  badge.style.setProperty("--color-select-color", select.value);
}

function initializeColorSelectPreviews() {
  document.querySelectorAll("[data-color-select]").forEach((select) => {
    refreshColorBadge(select);
  });
}

document.addEventListener("change", (event) => {
  const select = event.target.closest("[data-color-select]");

  if (select) refreshColorBadge(select);
});

document.addEventListener("turbo:load", initializeColorSelectPreviews);
document.addEventListener("turbo:frame-load", initializeColorSelectPreviews);
document.addEventListener("DOMContentLoaded", initializeColorSelectPreviews);
