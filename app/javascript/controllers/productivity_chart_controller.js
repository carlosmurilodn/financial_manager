import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

export default class extends Controller {
  static targets = ["canvas"]
  static values = { points: Array }

  connect() {
    this.render()
    this.observer = new MutationObserver(() => this.render())
    for (const element of [document.documentElement, document.body]) {
      this.observer.observe(element, { attributes: true, attributeFilter: ["class", "data-theme"] })
    }
  }

  disconnect() {
    this.observer?.disconnect()
    this.chart?.destroy()
  }

  render() {
    this.chart?.destroy()
    const styles = getComputedStyle(this.element)
    const text = styles.getPropertyValue("--text-main").trim() || "#334155"
    const primary = styles.getPropertyValue("--primary").trim() || "#6366f1"
    const grid = styles.getPropertyValue("--card-border").trim() || "#e2e8f0"
    const dateLabel = date => new Date(`${date}T12:00:00Z`).toLocaleDateString("pt-BR", { timeZone: "UTC" })
    this.chart = new Chart(this.canvasTarget, {
      type: "line",
      data: { labels: this.pointsValue.map(point => dateLabel(point.date)), datasets: [{ label: "Palavras", data: this.pointsValue.map(point => point.words), borderColor: primary, backgroundColor: primary, tension: 0, pointRadius: this.pointsValue.length > 90 ? 0 : 3, pointHitRadius: 12, borderWidth: 2 }] },
      options: { responsive: true, maintainAspectRatio: false, locale: "pt-BR", interaction: { mode: "index", intersect: false },
        plugins: { legend: { display: false }, tooltip: { callbacks: { label: item => `${item.parsed.y.toLocaleString("pt-BR")} palavras` } } },
        scales: { x: { grid: { display: false }, ticks: { color: text, maxTicksLimit: 8 } }, y: { beginAtZero: true, grid: { color: grid }, ticks: { color: text, precision: 0 } } }
      }
    })
  }
}
