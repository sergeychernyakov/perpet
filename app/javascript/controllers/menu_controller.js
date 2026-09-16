import { Controller } from "@hotwired/stimulus"

// Мобильное меню в шапке.
export default class extends Controller {
  static targets = ["panel"]

  toggle() {
    this.panelTarget.dataset.open = this.panelTarget.dataset.open === "true" ? "false" : "true"
  }

  close() {
    this.panelTarget.dataset.open = "false"
  }
}
