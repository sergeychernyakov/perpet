import { Controller } from "@hotwired/stimulus"

const TITLES = {
  join: "Присоединиться",
  respond: "Отклик на объявление"
}

const NOTES = {
  join: () => "Оставьте контакт — расскажем, как передержать питомца с PERPET.",
  respond: (subject) =>
    subject ? `Вы откликаетесь: ${subject}` : "Оставьте контакт, и хозяин с вами свяжется."
}

// Окно заявки: «присоединиться» на страницах и «откликнуться» в объявлениях.
export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    this.template = this.body.innerHTML
  }

  open(event) {
    const kind = event.params.kind || "join"
    const subject = event.params.subject || ""

    this.body.innerHTML = this.template
    this.set("title", TITLES[kind])
    this.set("note", NOTES[kind](subject))
    this.setValue("kind", kind)
    this.setValue("subject", subject)

    this.dialogTarget.hidden = false
    document.body.style.overflow = "hidden"
    this.find("firstField")?.focus()
  }

  close() {
    this.dialogTarget.hidden = true
    document.body.style.overflow = ""
  }

  backdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  get body() {
    return this.dialogTarget.querySelector("#modal-body")
  }

  find(name) {
    return this.body.querySelector(`[data-modal-target="${name}"]`)
  }

  set(name, text) {
    const node = this.find(name)
    if (node) node.textContent = text
  }

  setValue(name, value) {
    const node = this.find(name)
    if (node) node.value = value
  }
}
