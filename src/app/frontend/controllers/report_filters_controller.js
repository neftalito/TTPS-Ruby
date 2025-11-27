import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // 1. Agregamos startDate y endDate a los targets
  static targets = ["customRange", "startDate", "endDate"]

  connect() {
    const urlParams = new URLSearchParams(window.location.search)
    if (urlParams.get('range') === 'custom') {
      this.customRangeTarget.classList.remove('hidden')
    }
    // Ejecutamos la validación al cargar por si ya vienen fechas
    this.updateConstraints()
  }

  toggle(event) {
    this.customRangeTarget.classList.remove('hidden')
  }

  // 2. Nueva función: Ajusta los límites de los calendarios
  updateConstraints() {
    const start = this.startDateTarget.value
    const end = this.endDateTarget.value

    if (start) {
      // La fecha fin no puede ser menor a la fecha inicio
      this.endDateTarget.min = start
    }

    if (end) {
      // La fecha inicio no puede ser mayor a la fecha fin
      this.startDateTarget.max = end
    }
  }
}