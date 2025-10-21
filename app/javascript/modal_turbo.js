document.addEventListener("turbo:frame-load", function(event) {
  if (event.target.id === "modal") {
    const modalBody = document.getElementById("modal-body");
    const modalElement = document.getElementById("turboModal");

    if (!modalBody || !modalElement) return;

    modalBody.innerHTML = event.target.innerHTML;

    const modal = bootstrap.Modal.getOrCreateInstance(modalElement);
    modal.show();

    // Limpa o conteúdo quando o modal for fechado
    modalElement.addEventListener(
      "hidden.bs.modal",
      () => {
        modalBody.innerHTML = "";
      },
      { once: true }
    );
  }
});
