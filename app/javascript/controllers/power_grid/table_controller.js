import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "form" ]

  connect() {
    console.log("PowerGrid Table Controller connected")
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit()
    }, 300)
  }
}
