import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["customRange"]

  connect() {
    // Si la URL tiene fechas personalizadas (no predefinidas), abrimos el panel
    const urlParams = new URLSearchParams(window.location.search)
    if (urlParams.get('range') === 'custom') {
      this.customRangeTarget.classList.remove('hidden')
    }
  }

  toggle(event) {
    // Si elige "Personalizado", mostramos los inputs.
    // Si elige otro, el link recargará la página, así que no importa.
    this.customRangeTarget.classList.remove('hidden')
  }
}