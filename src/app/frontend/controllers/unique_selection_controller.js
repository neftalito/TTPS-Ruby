import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  connect() {
    this.updateOptions()
  }


  selectTargetConnected() {
    this.updateOptions()
  }


  selectTargetDisconnected() {
    this.updateOptions()
  }

 
  change(event) {
    this.updateOptions()
  }

  updateOptions() {

    const selectedValues = this.selectTargets
      .map(select => select.value)
      .filter(value => value !== "")


    this.selectTargets.forEach(select => {
      Array.from(select.options).forEach(option => {

        if (option.value === "") return


        const isSelectedElsewhere = selectedValues.includes(option.value) && select.value !== option.value

        if (isSelectedElsewhere) {

          option.disabled = true
          option.innerText = ` ${option.text.replace("", "")}` 
        } else {

          option.disabled = false
          option.innerText = option.text.replace("", "")
        }
      })
    })
  }
}