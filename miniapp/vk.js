// Всё, что мы берём у ВКонтакте через VK Bridge.
//
// Вне VK моста нет — тогда каждая функция просто возвращает пустоту,
// и приложение работает как обычная страница.
import { VK_APP_ID } from "./config.js"

let user = null

export function bridge() {
  return window.vkBridge || null
}

export function vkUser() {
  return user
}

// Вне ВКонтакте мост загружается, но на запросы никто не отвечает —
// обещание висит вечно. Поэтому ждём ответ не дольше пары секунд.
function within(promise, ms = 2500) {
  return Promise.race([
    promise,
    new Promise((_, reject) => setTimeout(() => reject(new Error("VK не ответил")), ms))
  ])
}

export async function connect({ onAppearance } = {}) {
  const vk = bridge()
  if (!vk) return null

  try {
    await within(vk.send("VKWebAppInit"))
    user = await within(vk.send("VKWebAppGetUserInfo"))
  } catch {
    user = null
    return null
  }

  if (onAppearance) {
    vk.subscribe(({ detail }) => {
      if (detail?.type === "VKWebAppUpdateConfig") onAppearance(detail.data.appearance)
    })
  }

  return user
}

// Имя и город из VK — чтобы человек не перепечатывал то, что и так известно.
export function suggestedProfile() {
  if (!user) return null

  return {
    name: [ user.first_name, user.last_name ].filter(Boolean).join(" "),
    city: user.city?.title || ""
  }
}

export function avatarUrl() {
  return user?.photo_200 || user?.photo_100 || null
}

// Профиль создаётся с техническим именем вида «vk-4242» — его и заменяем.
export function untouchedName(name) {
  return !name || /^vk-\d+$/.test(name)
}

export function appLink() {
  return `https://vk.com/app${VK_APP_ID}`
}

// Запись на стену с текстом объявления. VK сам покажет окно подтверждения,
// без согласия человека ничего не публикуется.
export async function shareAd(ad) {
  const vk = bridge()
  if (!vk) throw new Error("Поделиться можно только внутри ВКонтакте")

  const lines = [
    `Ищу передержку: ${ad.title}`,
    [ ad.city, ad.period ].filter(Boolean).join(", "),
    ad.price,
    ad.description,
    `Откликнуться в PERPET: ${appLink()}`
  ].filter(Boolean)

  return vk.send("VKWebAppShowWallPostBox", { message: lines.join("\n") })
}
