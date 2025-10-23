// app/javascript/utils.js

/**
 * Formata um input como moeda brasileira (R$ 0.000,00)
 * @param {HTMLInputElement} el 
 */
export function formatMoeda(el) {
  let val = el.value.replace(/\D/g, "");

  if (!val) {
    el.value = "R$ 0,00";
    return;
  }

  val = (parseInt(val) / 100).toFixed(2);
  let partes = val.split(".");
  let inteiro = partes[0];
  let decimal = partes[1];
  inteiro = inteiro.replace(/\B(?=(\d{3})+(?!\d))/g, ".");
  el.value = "R$ " + inteiro + "," + decimal;
}

/**
 * Formata um input como número de cartão (XXXX XXXX XXXX XXXX)
 * @param {HTMLInputElement} input 
 */
export function formatCardNumber(input) {
  let value = input.value.replace(/\D/g, "").slice(0, 16);
  input.value = value.replace(/(.{4})/g, "$1 ").trim();
}

/**
 * Inicializa formatação e listeners do formulário
 */
export const initializeFormUtils = () => {
  // Formata moedas
  document.querySelectorAll(".moeda").forEach(formatMoeda);
  document.querySelectorAll(".moeda").forEach(input =>
    input.addEventListener("input", () => formatMoeda(input))
  );

  // Formata números de cartão
  document.querySelectorAll(".card-number").forEach(input =>
    input.addEventListener("input", () => formatCardNumber(input))
  );
};

// Garante execução na carga inicial e em cada visita do Turbo
document.addEventListener("turbo:load", initializeFormUtils);
document.addEventListener("turbo:render", initializeFormUtils);