import { Controller } from "@hotwired/stimulus"

const MINIMUM = 20

// Счётчик символов под полем обращения в поддержку.
export default class extends Controller {
  static targets = ["input", "output"]

  connect() {
    this.update()
  }

  update() {
    const length = this.inputTarget.value.trim().length

    this.outputTarget.textContent = length < MINIMUM
      ? `Ещё ${MINIMUM - length} символов`
      : `${this.inputTarget.value.length} символов`
  }
}
