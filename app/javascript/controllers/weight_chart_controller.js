import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

export default class extends Controller {
  static targets = ["canvas"]
  static values = { points: Array, goal: Number }

  connect() {
    this.renderChart()
    this.themeObserver = new MutationObserver(() => this.renderChart())
    const options = { attributes: true, attributeFilter: ["class", "data-theme", "style"] }
    this.themeObserver.observe(document.documentElement, options)
    this.themeObserver.observe(document.body, options)
  }

  disconnect() {
    this.themeObserver?.disconnect()
    this.destroyChart()
  }

  destroyChart() {
    this.chart?.destroy()
    this.chart = null
  }

  renderChart() {
    this.destroyChart()
    const points = this.pointsValue.map(({ date, weight }) => ({ x: Date.parse(`${date}T00:00:00Z`), y: weight }))
    if (!points.length) return
    const styles = getComputedStyle(this.element)
    const text = styles.getPropertyValue("--text-main").trim() || "#334155"
    const primary = styles.getPropertyValue("--primary").trim() || "#2563eb"
    const grid = styles.getPropertyValue("--table-border-color").trim() || "#cbd5e1"
    const dateLabel = (value) => new Date(value).toLocaleDateString("pt-BR", { timeZone: "UTC" })
    const weightLabel = (value) => `${Number(value).toLocaleString("pt-BR", { maximumFractionDigits: 2 })} kg`
    const first = points[0].x
    const last = points[points.length - 1].x
    const min = first === last ? first - 86400000 : first
    const max = first === last ? last + 86400000 : last
    const datasets = [{ label: "Peso registrado", data: points, borderColor: primary, backgroundColor: primary, pointRadius: 4, pointHitRadius: 12, borderWidth: 2, tension: 0, fill: false }]
    if (this.goalValue > 0) datasets.push({ label: "Peso desejado", data: [{ x: min, y: this.goalValue }, { x: max, y: this.goalValue }], borderColor: text, borderDash: [6, 6], pointRadius: 0, pointHitRadius: 0, borderWidth: 2 })
    this.chart = new Chart(this.canvasTarget, {
      type: "line",
      data: { datasets },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        animation: false,
        locale: "pt-BR",
        plugins: {
          legend: { labels: { color: text } },
          tooltip: { callbacks: {
            title: (items) => dateLabel(items[0].parsed.x),
            label: (item) => `${item.dataset.label}: ${weightLabel(item.parsed.y)}`
          } }
        },
        scales: {
          x: { type: "linear", min, max, grid: { color: grid }, ticks: { color: text, maxTicksLimit: 6, callback: dateLabel } },
          y: { grid: { color: grid }, ticks: { color: text, callback: weightLabel }, title: { display: true, text: "Peso (kg)", color: text } }
        }
      }
    })
  }
}
