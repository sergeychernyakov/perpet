// Мелкие помощники разметки: без фреймворка, но и без склейки строк руками.

export function el(tag, props = {}, children = []) {
  const node = document.createElement(tag)

  Object.entries(props).forEach(([key, value]) => {
    if (value === null || value === undefined || value === false) return

    if (key === "class") node.className = value
    else if (key === "text") node.textContent = value
    else if (key.startsWith("on")) node.addEventListener(key.slice(2).toLowerCase(), value)
    else node.setAttribute(key, value === true ? "" : value)
  })

  ;[].concat(children).filter(Boolean).forEach((child) => node.append(child))

  return node
}

export function field(label, name, { value = "", type = "text", rows, placeholder } = {}) {
  const input = rows
    ? el("textarea", { name, rows, placeholder })
    : el("input", { name, type, placeholder })

  input.value = value || ""

  return el("label", { class: "field" }, [ el("span", { text: label }), input ])
}

export function skeletons(count = 3) {
  return Array.from({ length: count }, () => el("div", { class: "skeleton" }))
}

export function notice(text) {
  return el("p", { class: "notice", text })
}

export function error(messages) {
  return el("p", { class: "error", text: [].concat(messages).join(". ") })
}
