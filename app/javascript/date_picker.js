document.addEventListener("turbo:render", function () {
    // Toggle parcelamento (mantido)
    const paymentSelect = document.getElementById("payment_method_select");
    const parcelSection = document.getElementById("parcelamento_section");

    if (paymentSelect && parcelSection) {
      function toggleParcelSection() {
        parcelSection.style.display =
          paymentSelect.value === "credito_parcelado" ? "flex" : "none";
      }
      paymentSelect.addEventListener("change", toggleParcelSection);
      toggleParcelSection();
    }

    // Calendário customizado
    const allInputs = document.querySelectorAll(".custom-date");

    const holidays = {
      "01/01": "Confraternização Universal",
      "21/04": "Tiradentes",
      "01/05": "Dia do Trabalhador",
      "07/09": "Independência do Brasil",
      "12/10": "Nossa Senhora Aparecida",
      "02/11": "Finados",
      "15/11": "Proclamação da República",
      "24/10": "Aniversário de Goiânia",
      "28/10": "Dia do Servidor Público",
      "20/11": "Consciência Negra",
      "08/12": "Imaculada Conceição",
      "14/12": "Fundação de Goiânia",
      "25/12": "Natal"
    };

    allInputs.forEach((input) => {
      if (input.value && input.value.match(/^\d{4}-\d{2}-\d{2}$/)) {
        const [y, m, d] = input.value.split("-");
        input.value = `${d}/${m}/${y}`;
      }

      input.addEventListener("focus", function () {
        const existingPicker = document.querySelector(".datepicker");
        if (existingPicker) existingPicker.remove();

        const picker = document.createElement("div");
        picker.classList.add("datepicker");

        let current =
          input.value && input.value.match(/^\d{2}\/\d{2}\/\d{4}$/)
            ? parseDate(input.value)
            : new Date();

        renderCalendar(picker, current, input);
        input.parentNode.appendChild(picker);

        function handleClickOutside(e) {
          if (
            !e.target.closest(".custom-date-wrapper") &&
            !e.target.closest(".datepicker")
          ) {
            picker.remove();
            document.removeEventListener("click", handleClickOutside);
          }
        }

        // Delay para não fechar ao clicar no botão de mês
        setTimeout(() => {
          document.addEventListener("click", handleClickOutside);
        }, 0);
      });

      function renderCalendar(picker, date, input) {
        const month = date.getMonth();
        const year = date.getFullYear();
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const firstDay = new Date(year, month, 1).getDay();
        const monthNames = [
          "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
          "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
        ];
        
        // Lógica para popular o seletor de Mês
        let monthOptions = monthNames.map((name, i) => 
            `<option value="${i}" ${i === month ? 'selected' : ''}>${name}</option>`
        ).join("");

        // Lógica para popular o seletor de Ano (±10 anos)
        const currentYear = new Date().getFullYear();
        const startYear = currentYear - 10;
        const endYear = currentYear + 10;
        let yearOptions = "";
        
        for (let y = startYear; y <= endYear; y++) {
          yearOptions += `<option value="${y}" ${y === year ? 'selected' : ''}>${y}</option>`;
        }


        picker.innerHTML = `
          <div class="datepicker-header">
            <button type="button" class="prev-month">&lt;</button>
            <div class="month-year-selects">
                <select class="select-month">${monthOptions}</select>
                <select class="select-year">${yearOptions}</select>
            </div>
            <button type="button" class="next-month">&gt;</button>
          </div>
          <table>
            <thead>
              <tr>${["D", "S", "T", "Q", "Q", "S", "S"]
                .map((d) => `<th>${d}</th>`)
                .join("")}</tr>
            </thead>
            <tbody></tbody>
          </table>
        `;

        const tbody = picker.querySelector("tbody");
        let html = "<tr>";
        for (let i = 0; i < firstDay; i++) html += "<td></td>";

        for (let d = 1; d <= daysInMonth; d++) {
          const dayOfWeek = new Date(year, month, d).getDay();
          const formatted = formatDateDisplay(year, month, d);
          const shortDate = formatted.slice(0, 5);
          let cls = "";
          let title = "";

          if (dayOfWeek === 0) cls += "sunday ";
          if (dayOfWeek === 6) cls += "saturday "; // NOVO: Adiciona a classe para sábado
          
          if (holidays[shortDate]) {
            cls += "holiday ";
            title = holidays[shortDate];
          }

          html += `<td data-date="${formatted}" class="${cls.trim()}" ${
            title ? `title="${title}"` : ""
          }>${d}</td>`;

          if ((firstDay + d) % 7 === 0) html += "</tr><tr>";
        }

        html += "</tr>";
        tbody.innerHTML = html;

        picker.querySelectorAll("td[data-date]").forEach((td) => {
          td.addEventListener("click", () => {
            input.value = td.dataset.date;
            picker.remove();
          });
        });

        // Eventos dos botões de navegação (setas)
        picker.querySelector(".prev-month").addEventListener("click", (e) => {
          e.stopPropagation();
          renderCalendar(picker, new Date(year, month - 1, 1), input);
        });

        picker.querySelector(".next-month").addEventListener("click", (e) => {
          e.stopPropagation();
          renderCalendar(picker, new Date(year, month + 1, 1), input);
        });
        
        // Eventos dos seletores (Mês e Ano)
        picker.querySelector(".select-month").addEventListener("change", function(e) {
            e.stopPropagation();
            const newMonth = parseInt(this.value);
            renderCalendar(picker, new Date(year, newMonth, 1), input);
        });

        picker.querySelector(".select-year").addEventListener("change", function(e) {
            e.stopPropagation();
            const newYear = parseInt(this.value);
            renderCalendar(picker, new Date(newYear, month, 1), input);
        });
      }

      function formatDateDisplay(y, m, d) {
        return `${String(d).padStart(2, "0")}/${String(m + 1).padStart(
          2,
          "0"
        )}/${y}`;
      }

      function parseDate(str) {
        const [d, m, y] = str.split("/");
        return new Date(y, m - 1, d);
      }
    });
  });