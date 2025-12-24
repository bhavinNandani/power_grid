import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

// Connects to data-controller="power-grid--flatpickr"
export default class extends Controller {
    connect() {
        this.fp = flatpickr(this.element, {
            mode: "range",
            dateFormat: "Y-m-d",
            altInput: true,
            altFormat: "F j, Y",
            onChange: (selectedDates, dateStr, instance) => {
                if (selectedDates.length === 2 || selectedDates.length === 0) {
                    this.element.form.requestSubmit()
                }
            }
        })
    }

    disconnect() {
        this.fp.destroy()
    }
}
