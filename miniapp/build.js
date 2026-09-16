// Сборки как таковой нет: приложение — обычная статика.
// Скрипт просто складывает файлы в build/, как ждёт vk-miniapps-deploy.
const fs = require("node:fs")
const path = require("node:path")

const FILES = ["index.html", "app.css", "app.js", "api.js", "ui.js", "config.js"]
const out = path.join(__dirname, "build")

fs.rmSync(out, { recursive: true, force: true })
fs.mkdirSync(out)
FILES.forEach((file) => fs.copyFileSync(path.join(__dirname, file), path.join(out, file)))

console.log(`Готово: ${FILES.length} файлов в build/`)
