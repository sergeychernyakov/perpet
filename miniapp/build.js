// Сборки как таковой нет: приложение — обычная статика.
// Скрипт складывает её в build/, как ждёт vk-miniapps-deploy.
//
// Список файлов не перечисляем руками: один забытый модуль — и приложение
// не стартует вовсе, а VK показывает «App not detected». Берём всё, кроме
// служебного.
const fs = require("node:fs")
const path = require("node:path")

const SKIP = new Set([ "build", "node_modules", "build.js", "package.json",
                       "package-lock.json", "vk-hosting-config.json", "build.zip",
                       "README.md", ".gitignore", ".DS_Store" ])

const out = path.join(__dirname, "build")
fs.rmSync(out, { recursive: true, force: true })
fs.mkdirSync(out)

const copied = fs.readdirSync(__dirname).filter((name) => {
  if (SKIP.has(name) || name.startsWith(".")) return false

  return fs.statSync(path.join(__dirname, name)).isFile()
})

copied.forEach((name) => fs.copyFileSync(path.join(__dirname, name), path.join(out, name)))

// index.html — точка входа, без неё выкладывать нечего.
if (!copied.includes("index.html")) {
  throw new Error("В build/ не попал index.html")
}

// Каждый импорт из модулей должен оказаться в сборке.
const missing = []
copied.filter((name) => name.endsWith(".js")).forEach((name) => {
  const source = fs.readFileSync(path.join(out, name), "utf8")

  for (const match of source.matchAll(/from\s+"\.\/([^"]+)"/g)) {
    if (!copied.includes(match[1])) missing.push(`${name} → ${match[1]}`)
  }
})

if (missing.length) {
  throw new Error(`Не хватает файлов в сборке: ${missing.join(", ")}`)
}

console.log(`Готово: ${copied.length} файлов в build/ (${copied.join(", ")})`)
