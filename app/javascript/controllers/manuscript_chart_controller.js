import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

export default class extends Controller {
  static targets = ["canvas"]
  static values = { chapters: Array }

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
    this.chart = new Chart(this.canvasTarget, {
      type: "bar",
      data: {
        labels: this.chaptersValue.map(chapter => `Cap. ${chapter.order}`),
        datasets: [{ label: "Palavras", data: this.chaptersValue.map(chapter => chapter.words), backgroundColor: primary, borderRadius: 8 }]
      },
      options: {
        responsive: true, maintainAspectRatio: false, locale: "pt-BR",
        plugins: { legend: { display: false }, tooltip: { callbacks: {
          title: items => this.chaptersValue[items[0].dataIndex].title,
          label: item => `${item.parsed.y.toLocaleString("pt-BR")} palavras`
        } } },
        scales: {
          x: { grid: { display: false }, ticks: { color: text, maxTicksLimit: 12 } },
          y: { beginAtZero: true, grid: { color: grid }, ticks: { color: text, precision: 0 } }
        }
      }
    })
  }
}
