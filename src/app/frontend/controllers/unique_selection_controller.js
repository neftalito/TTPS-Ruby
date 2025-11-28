import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  connect() {
    this.updateOptions()
  }

  // Se ejecuta automáticamente cuando agregas una nueva fila (gracias a Stimulus)
  selectTargetConnected() {
    this.updateOptions()
  }

  // Se ejecuta automáticamente cuando eliminas una fila
  selectTargetDisconnected() {
    this.updateOptions()
  }

  // Se ejecuta cuando el usuario cambia una opción manualmente
  change(event) {
    this.updateOptions()
  }

  updateOptions() {
    // 1. Recopilamos todos los IDs que ya están seleccionados
    const selectedValues = this.selectTargets
      .map(select => select.value)
      .filter(value => value !== "") // Ignoramos los vacíos

    // 2. Recorremos cada select para actualizar sus opciones
    this.selectTargets.forEach(select => {
      Array.from(select.options).forEach(option => {
        // Ignoramos el placeholder vacío
        if (option.value === "") return

        // Chequeamos si este valor está seleccionado en OTRO input
        const isSelectedElsewhere = selectedValues.includes(option.value) && select.value !== option.value

        if (isSelectedElsewhere) {
          // Si ya se usó, lo deshabilitamos y le cambiamos el color
          option.disabled = true
          option.innerText = `⛔ ${option.text.replace("⛔ ", "")}` // Marcador visual
        } else {
          // Si está libre, lo habilitamos y limpiamos el texto
          option.disabled = false
          option.innerText = option.text.replace("⛔ ", "")
        }
      })
    })
  }
}