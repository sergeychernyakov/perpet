// Клиент API основного сайта PERPET.
//
// Адрес берётся из ?api= (удобно для отладки), иначе — из config.js.
import { API_BASE } from "./config.js"

const override = new URLSearchParams(location.search).get("api")

export const apiBase = (override || API_BASE).replace(/\/$/, "")

// Параметры запуска VK приходят в query string и подписаны защищённым ключом.
// Пересылаем их как есть — сервер проверит подпись сам.
export const launchParams = location.search.replace(/^\?/, "")

export class ApiError extends Error {
  constructor(messages, status) {
    super(messages[0] || "Что-то пошло не так")
    this.messages = messages
    this.status = status
  }
}

async function request(path, { method = "GET", body } = {}) {
  let response

  try {
    response = await fetch(apiBase + path, {
      method,
      headers: Object.assign(
        { Accept: "application/json", "X-VK-Launch-Params": launchParams },
        body ? { "Content-Type": "application/json" } : {}
      ),
      body: body ? JSON.stringify(body) : undefined
    })
  } catch {
    throw new ApiError(["Нет связи с сервером PERPET"], 0)
  }

  if (response.status === 204) return {}

  const data = await response.json().catch(() => ({}))

  if (!response.ok) {
    throw new ApiError(data.errors || [data.error || "Сервер вернул ошибку"], response.status)
  }

  return data
}

export const api = {
  ads: (params) => request("/api/v1/ads?" + new URLSearchParams(params)),
  ad: (id) => request(`/api/v1/ads/${id}`),
  myAds: () => request("/api/v1/ads/mine"),
  createAd: (ad) => request("/api/v1/ads", { method: "POST", body: { ad } }),
  deleteAd: (id) => request(`/api/v1/ads/${id}`, { method: "DELETE" }),
  articles: (params) => request("/api/v1/articles?" + new URLSearchParams(params)),
  article: (id) => request(`/api/v1/articles/${id}`),
  profile: () => request("/api/v1/profile"),
  updateProfile: (profile) => request("/api/v1/profile", { method: "PATCH", body: { profile } }),
  support: () => request("/api/v1/support"),
  createLead: (lead) => request("/api/v1/leads", { method: "POST", body: { lead } }),
  createTicket: (ticket) => request("/api/v1/support_tickets", { method: "POST", body: { support_ticket: ticket } })
}
