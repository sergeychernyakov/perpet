import { Controller } from "@hotwired/stimulus"

// Фотографии уменьшает браузер, а не сервер: на сервере нет ни libvips,
// ни места под оригиналы с телефона. Снимок на 4 МБ превращается в 200–400 КБ
// без заметной потери качества в карточке.
const MAX_SIDE = 1400
const QUALITY = 0.82

export default class extends Controller {
  static targets = ["input", "preview", "note"]

  async choose() {
    const file = this.inputTarget.files[0]
    if (!file) return this.reset()

    if (!file.type.startsWith("image/")) {
      this.say("Это не картинка — выберите JPEG, PNG или WebP")
      this.inputTarget.value = ""
      return
    }

    this.say("Готовим картинку…")

    try {
      const smaller = await this.shrink(file)
      this.replaceFile(smaller)
      this.show(smaller)
      this.say(`${Math.round(smaller.size / 1024)} КБ — столько уйдёт на сервер`)
    } catch {
      // Не получилось уменьшить — отправим как есть, сервер проверит размер.
      this.show(file)
      this.say("Уменьшить не вышло, отправим как есть")
    }
  }

  async shrink(file) {
    const bitmap = await createImageBitmap(file)
    const scale = Math.min(1, MAX_SIDE / Math.max(bitmap.width, bitmap.height))

    const canvas = document.createElement("canvas")
    canvas.width = Math.round(bitmap.width * scale)
    canvas.height = Math.round(bitmap.height * scale)
    canvas.getContext("2d").drawImage(bitmap, 0, 0, canvas.width, canvas.height)
    bitmap.close()

    const blob = await new Promise((resolve) => canvas.toBlob(resolve, "image/jpeg", QUALITY))
    if (!blob) throw new Error("canvas не отдал картинку")

    return new File([ blob ], file.name.replace(/\.\w+$/, "") + ".jpg", { type: "image/jpeg" })
  }

  // Подменяем файл в поле, чтобы форма отправила уменьшенный.
  replaceFile(file) {
    const box = new DataTransfer()
    box.items.add(file)
    this.inputTarget.files = box.files
  }

  show(file) {
    if (!this.hasPreviewTarget) return

    URL.revokeObjectURL(this.previewTarget.src)
    this.previewTarget.src = URL.createObjectURL(file)
    this.previewTarget.hidden = false
  }

  reset() {
    if (this.hasPreviewTarget) this.previewTarget.hidden = true
    this.say("")
  }

  say(text) {
    if (this.hasNoteTarget) this.noteTarget.textContent = text
  }
}
