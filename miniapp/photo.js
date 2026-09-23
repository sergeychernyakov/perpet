// Поле фотографии в мини-приложении.
//
// Картинку уменьшает телефон, а не сервер: снимок на 4 МБ превращается
// в 200–400 КБ, и загрузка по мобильному интернету занимает секунду,
// а не минуту.
import { el } from "./ui.js"

const MAX_SIDE = 1400
const QUALITY = 0.82

export async function shrink(file) {
  const bitmap = await createImageBitmap(file)
  const scale = Math.min(1, MAX_SIDE / Math.max(bitmap.width, bitmap.height))

  const canvas = document.createElement("canvas")
  canvas.width = Math.round(bitmap.width * scale)
  canvas.height = Math.round(bitmap.height * scale)
  canvas.getContext("2d").drawImage(bitmap, 0, 0, canvas.width, canvas.height)
  bitmap.close()

  const blob = await new Promise((resolve) => canvas.toBlob(resolve, "image/jpeg", QUALITY))
  if (!blob) throw new Error("не удалось уменьшить")

  return new File([ blob ], file.name.replace(/\.\w+$/, "") + ".jpg", { type: "image/jpeg" })
}

// Возвращает поле и функцию, которая отдаёт выбранный файл (уже уменьшенный).
// plus: true — вид из макета: круглый «+» и подпись под ним.
export function photoField(label, { current, plus = false } = {}) {
  let chosen = null

  const preview = el("img", { class: plus ? "photo__preview photo-field__preview" : "photo__preview", alt: "" })
  preview.hidden = !current
  if (current) preview.src = current

  const note = el("p", { class: "muted", text: "" })
  const input = el("input", { type: "file", accept: "image/jpeg,image/png,image/webp", class: "photo__input" })

  input.addEventListener("change", async () => {
    const file = input.files[0]
    if (!file) return

    note.textContent = "Готовим картинку…"

    try {
      chosen = await shrink(file)
    } catch {
      chosen = file
    }

    URL.revokeObjectURL(preview.src)
    preview.src = URL.createObjectURL(chosen)
    preview.hidden = false
    note.textContent = `${Math.round(chosen.size / 1024)} КБ`
  })

  const field = plus
    ? el("div", { class: "photo-field photo-field--plus" }, [
        el("div", { class: "photo-field__row" }, [
          preview,
          el("label", { class: "photo-field__plus", title: "Выбрать фото" }, [
            el("span", { "aria-hidden": "true", text: "+" }), input
          ])
        ]),
        el("span", { class: "photo-field__caption", text: label }),
        note
      ])
    : el("div", { class: "field photo" }, [
        el("span", { text: label }),
        el("div", { class: "photo__row" }, [
          preview,
          el("label", { class: "btn" }, [ "Выбрать фото", input ])
        ]),
        note
      ])

  return { field, file: () => chosen }
}
