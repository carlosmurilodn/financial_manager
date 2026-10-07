import { Controller } from '@hotwired/stimulus'
import { application } from './controllers/application'
import Chart from 'chart.js/auto'

class SelfKnowledgeChartController extends Controller {
  static targets = ['canvas']
  static values = { points: Array, label: String }
  connect() {
    this.renderChart()
    this.observer = new MutationObserver(() => this.renderChart())
    const options = { attributes: true, attributeFilter: ['class', 'data-theme', 'style'] }
    this.observer.observe(document.documentElement, options)
    this.observer.observe(document.body, options)
  }
  disconnect() { this.observer?.disconnect(); this.chart?.destroy() }
  renderChart() {
    this.chart?.destroy()
    const styles = getComputedStyle(this.element)
    const color = styles.getPropertyValue('--nav-active-bar').trim()
    const text = styles.getPropertyValue('--text-main').trim()
    const grid = styles.getPropertyValue('--card-border').trim()
    const dates = this.pointsValue.map((point) => ({ x: Date.parse(`${point.date}T00:00:00Z`), y: point.value }))
    const label = (value) => new Date(value).toLocaleDateString('pt-BR', { timeZone: 'UTC' })
    const first = dates[0].x, last = dates[dates.length - 1].x
    this.chart = new Chart(this.canvasTarget, {
      type: 'line', data: { datasets: [{ label: this.labelValue, data: dates, borderColor: color, backgroundColor: color, pointRadius: 4, pointHitRadius: 12, tension: 0, spanGaps: false }] },
      options: { responsive: true, maintainAspectRatio: false, animation: false, plugins: { legend: { labels: { color: text } }, tooltip: { callbacks: { title: (items) => label(items[0].parsed.x) } } }, scales: { x: { type: 'linear', min: first === last ? first - 86400000 : first, max: first === last ? last + 86400000 : last, ticks: { color: text, maxTicksLimit: 6, callback: label }, grid: { color: grid } }, y: { min: 1, max: 5, ticks: { stepSize: 1, color: text }, grid: { color: grid } } } }
    })
  }
}
application.register('self-knowledge-chart', SelfKnowledgeChartController)

function initializeForms() {
  document.querySelectorAll('[data-self-knowledge-form]').forEach((form) => {
    if (form.dataset.bound) return
    form.dataset.bound = 'true'
    let dirty = false
    const stages = [...form.querySelectorAll('[data-self-stage]')]
    let position = Math.max(0, Math.min(Number(form.dataset.initialStep) || 0, stages.length - 1))
    const render = (focus = false) => {
      stages.forEach((stage, i) => { stage.hidden = i !== position })
      const tabs = form.querySelector('[data-self-stages]')
      if (!tabs) return
      tabs.replaceChildren(...stages.map((stage, i) => {
        const button = document.createElement('button')
        button.type = 'button'
        button.textContent = `${i + 1} · ${stage.querySelector('h2').textContent}`
        button.className = `self-knowledge-stage-link${i === position ? ' is-active' : ''}`
        if (i === position) button.setAttribute('aria-current', 'step')
        button.addEventListener('click', () => { position = i; render(true) })
        return button
      }))
      form.querySelector('[data-self-position]').textContent = `Etapa ${position + 1} de ${stages.length}`
      form.querySelector('[data-self-prev]').disabled = position === 0
      const next = form.querySelector('[data-self-continue]')
      next.hidden = position === stages.length - 1
      next.value = String(position + 1)
      if (focus) stages[position].querySelector('textarea, input')?.focus()
    }
    form.querySelector('[data-self-prev]')?.addEventListener('click', () => { position--; render(true) })
    const date = form.querySelector('[data-journal-date]')
    let promptRequest
    const updatePrompt = async () => {
      if (!date || !/^\d{2}\/\d{2}\/\d{4}$/.test(date.value)) return
      const [day, month, year] = date.value.split('/')
      promptRequest?.abort()
      promptRequest = new AbortController()
      try {
        const response = await fetch(`${date.dataset.promptUrl}?date=${year}-${month}-${day}`, { signal: promptRequest.signal, headers: { Accept: 'application/json' } })
        if (!response.ok) throw new Error('Falha ao carregar pergunta')
        const prompt = await response.json()
        form.querySelector('[data-rotating-question]').textContent = prompt.question
        form.querySelector('[data-rotating-help]').textContent = prompt.help
      } catch (error) {
        if (error.name !== 'AbortError') form.querySelector('[data-rotating-help]').textContent = 'Não foi possível atualizar a pergunta desta data. Tente selecionar o dia novamente antes de responder.'
      }
    }
    date?.addEventListener('change', updatePrompt)
    date?.addEventListener('input', updatePrompt)
    const week = form.querySelector('[data-self-knowledge-week]')
    let summaryRequest
    week?.addEventListener('change', async () => {
      summaryRequest?.abort()
      summaryRequest = new AbortController()
      const target = form.querySelector('[data-week-summary]')
      target.setAttribute('aria-busy', 'true')
      try {
        const response = await fetch(`${week.dataset.summaryUrl}?date=${week.value}`, { signal: summaryRequest.signal })
        if (!response.ok) throw new Error('Falha ao carregar resumo')
        target.innerHTML = await response.text()
      } catch (error) {
        if (error.name !== 'AbortError') target.textContent = 'Não foi possível carregar o resumo desta semana. Suas respostas continuam no formulário.'
      } finally { target.removeAttribute('aria-busy') }
    })
    form.addEventListener('input', () => { dirty = true })
    form.addEventListener('change', () => { dirty = true })
    form.addEventListener('submit', () => { dirty = false })
    window.addEventListener('beforeunload', (event) => { if (dirty && document.contains(form)) { event.preventDefault(); event.returnValue = '' } })
    document.addEventListener('turbo:before-visit', (event) => { if (dirty && document.contains(form) && !window.confirm('Existem alterações não salvas. Sair e descartá-las?')) event.preventDefault() })
    render()
  })
}
document.addEventListener('turbo:load', initializeForms)
document.addEventListener('turbo:render', initializeForms)
