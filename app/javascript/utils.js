// app/javascript/utils.js

/**
 * Função responsável por formatar um campo de input como moeda brasileira (R$ 0.000,00)
 *
 * @param {HTMLInputElement} el - O elemento input a ser formatado.
 */
export function formatMoeda(el) {
  let val = el.value.replace(/\D/g, "");

  if (!val) {
    el.value = "R$ 0,00";
    return;
  }

  // Converte para centavos e depois para float com duas casas decimais
  val = (parseInt(val) / 100).toFixed(2);
  
  let partes = val.split(".");
  let inteiro = partes[0];
  let decimal = partes[1];
  
  // Adiciona o separador de milhares (ponto)
  inteiro = inteiro.replace(/\B(?=(\d{3})+(?!\d))/g, ".");
  
  // Formata o valor final
  el.value = "R$ " + inteiro + "," + decimal;
}

/**
 * Função responsável por formatar um campo de input como número de cartão (adiciona espaço a cada 4 dígitos)
 *
 * @param {HTMLInputElement} input - O elemento input a ser formatado.
 */
export function formatCardNumber(input) {
  let value = input.value.replace(/\D/g, "")
  value = value.slice(0, 16)
  input.value = value.replace(/(.{4})/g, "$1 ").trim()
}

/**
 * Função de inicialização que roda após o carregamento da página e em cada visita do Turbo.
 * Ela configura a formatação inicial e os listeners de eventos.
 */
const initializeFormUtils = () => {
  // 1. Inicializa a formatação (ex: R$ 0,00 em vez de valor em branco ou 0)
  document.querySelectorAll(".moeda").forEach(el => formatMoeda(el));

  // 2. Adiciona o listener de 'input' para formatação DINÂMICA (enquanto o usuário digita)
  document.querySelectorAll(".moeda").forEach(input => {
    // Remove listeners antigos para evitar duplicação em visitas do Turbo
    // (O .addEventListener por si só já evita a duplicação se a referência for a mesma, mas é uma boa prática)
    // Para simplificar, confiamos no Turbo para limpar o DOM, mas garantimos a adição:
    input.addEventListener("input", () => formatMoeda(input));
  });

  // 3. Adiciona o listener para formatação de número de cartão
  document.querySelectorAll(".card-number").forEach(input => {
    input.addEventListener("input", () => formatCardNumber(input));
  });
};


document.addEventListener("turbo:frame-load", function  (event) {
    if (event.target.id === "modal") {
      const modalBody = document.getElementById("modal-body");
      const modalElement = document.getElementById("turboModal");
      modalBody.innerHTML = event.target.innerHTML;

      const modal = new bootstrap.Modal(modalElement);
      modal.show();

      // Limpa o conteúdo quando o modal for fechado
      modalElement.addEventListener("hidden.bs.modal", () => {
        modalBody.innerHTML = "";
      }, { once: true });
    }
  });
// Listener para o Turbo Rails: garante que o script seja executado
// na carga inicial e em todas as navegações do Turbo.
document.addEventListener("turbo:render", initializeFormUtils);
document.addEventListener("turbo:load", initializeFormUtils);

