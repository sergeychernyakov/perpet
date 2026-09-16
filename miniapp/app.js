import { api, ApiError } from "./api.js"
import { el, field, skeletons, notice, error } from "./ui.js"
import * as vk from "./vk.js"

const screen = document.getElementById("screen")
const tabbar = document.getElementById("tabbar")
const topbarNote = document.getElementById("topbar-note")
const sheet = document.getElementById("sheet")
const sheetBody = document.getElementById("sheet-body")

const state = { kind: "Все", query: "", page: 1 }
const KINDS = [ "Все", "Кошка", "Собака", "Грызун", "Птица" ]

// ---------- каркас ----------

function render(...nodes) {
  screen.replaceChildren(...nodes.flat().filter(Boolean))
  window.scrollTo(0, 0)
}

function banner(title, note) {
  return el("section", { class: "banner" }, [
    el("h1", { text: title }),
    note && el("p", { text: note })
  ])
}

function backButton(route) {
  return el("button", { class: "back", type: "button", onClick: () => go(route) }, "← Назад")
}

function openSheet(nodes) {
  sheetBody.replaceChildren(...[].concat(nodes).filter(Boolean))
  sheet.hidden = false
  document.body.style.overflow = "hidden"
}

function closeSheet() {
  sheet.hidden = true
  document.body.style.overflow = ""
}

document.getElementById("sheet-close").addEventListener("click", closeSheet)
sheet.addEventListener("click", (event) => { if (event.target === sheet) closeSheet() })
document.addEventListener("keydown", (event) => { if (event.key === "Escape") closeSheet() })

// ---------- объявления ----------

async function adsScreen() {
  const filters = el("div", { class: "filters" }, KINDS.map((kind) =>
    el("button", {
      class: "chip",
      type: "button",
      "aria-pressed": String(kind === state.kind),
      onClick: () => { state.kind = kind; state.page = 1; adsScreen() }
    }, kind)
  ))

  const input = el("input", { type: "search", placeholder: "кошка, Москва, июнь…", "aria-label": "Поиск" })
  input.value = state.query

  const search = el("form", {
    class: "search",
    onSubmit: (event) => { event.preventDefault(); state.query = input.value.trim(); state.page = 1; adsScreen() }
  }, [ input, el("button", { class: "btn btn--wine", type: "submit" }, "Найти") ])

  const list = el("div", { class: "form" })

  render(banner("Объявления", "Питомцы, которым нужна передержка"), filters, search, list)
  loadAds(list)
}

// Страницы не подменяют друг друга, а дописываются в конец списка — так
// привычнее на телефоне и не теряется то, что человек уже просмотрел.
async function loadAds(list, { append = false } = {}) {
  const tail = el("div", { class: "form" }, skeletons(append ? 1 : 3))
  append ? list.append(tail) : list.replaceChildren(tail)

  try {
    const { ads, meta } = await api.ads({ kind: state.kind, q: state.query, page: state.page })

    if (!ads.length) {
      tail.replaceWith(el("section", { class: "card card--flat" }, [
        el("h3", { text: "Ничего не нашлось" }),
        el("p", { class: "muted", text: "Попробуйте другой вид питомца или очистите поиск." })
      ]))
      return
    }

    const left = meta.total - meta.page * meta.per_page
    const more = left > 0 && el("button", {
      class: "btn btn--block",
      type: "button",
      onClick: (event) => { event.currentTarget.remove(); state.page += 1; loadAds(list, { append: true }) }
    }, `Показать ещё · осталось ${left}`)

    tail.replaceWith(...ads.map(adCard), ...(more ? [ more ] : []))
  } catch (failure) {
    tail.replaceWith(error(failure.messages))
  }
}

function adCard(ad) {
  return el("article", { class: "card" }, [
    el("span", { class: "tag", text: ad.kind }),
    el("h3", { text: ad.title }),
    ad.meta && el("p", { class: "card__meta", text: ad.meta }),
    ad.description && el("p", { text: ad.description }),
    el("div", { class: "card__foot" }, [
      el("span", { class: "price", text: ad.price || "цена по договорённости" }),
      el("div", { class: "card__buttons" }, [
        vk.bridge() && el("button", { class: "btn", type: "button", onClick: (event) => share(event, ad) }, "Поделиться"),
        el("button", { class: "btn btn--wine", type: "button", onClick: () => respondSheet(ad) }, "Откликнуться")
      ])
    ])
  ])
}

// Репост объявления на стену: окно подтверждения показывает сам ВКонтакте.
async function share(event, ad) {
  const button = event.currentTarget
  const label = button.textContent
  button.disabled = true

  try {
    await vk.shareAd(ad)
    button.textContent = "Отправлено"
  } catch {
    // Вне ВКонтакте моста нет, и человек должен понимать почему.
    button.textContent = "Только внутри VK"
    setTimeout(() => { button.textContent = label }, 2500)
  } finally {
    button.disabled = false
  }
}

// Отдельный экран объявления: на него ведёт ссылка из «Поделиться».
async function adScreen(id) {
  render(backButton("ads"), ...skeletons(2))

  try {
    const { ad } = await api.ad(id)

    render(
      backButton("ads"),
      banner(ad.title, [ ad.kind, ad.meta ].filter(Boolean).join(" · ")),
      el("section", { class: "card" }, [
        ad.description && el("p", { text: ad.description }),
        el("p", { class: "card__meta", text: ad.published_label }),
        el("div", { class: "card__foot" }, [
          el("span", { class: "price", text: ad.price || "цена по договорённости" }),
          el("div", { class: "card__buttons" }, [
            vk.bridge() && el("button", { class: "btn", type: "button", onClick: (event) => share(event, ad) }, "Поделиться"),
            el("button", { class: "btn btn--wine", type: "button", onClick: () => respondSheet(ad) }, "Откликнуться")
          ])
        ])
      ])
    )
  } catch (failure) {
    render(backButton("ads"), error(failure.messages))
  }
}

function respondSheet(ad) {
  const form = el("form", { class: "form", onSubmit: submit }, [
    el("h2", { id: "sheet-title", text: "Отклик на объявление" }),
    el("p", { class: "muted", text: `Вы откликаетесь: ${ad.title}` }),
    field("Имя", "name", { placeholder: "Анна" }),
    field("E-mail", "email", { type: "email", placeholder: "you@mail.ru" }),
    field("Город", "city", { placeholder: "Москва" }),
    el("button", { class: "btn btn--wine btn--block", type: "submit" }, "Отправить")
  ])

  openSheet(form)
  form.elements.name.focus()

  async function submit(event) {
    event.preventDefault()
    const button = form.querySelector("button[type=submit]")
    button.disabled = true
    form.querySelectorAll(".error").forEach((node) => node.remove())

    try {
      const { message } = await api.createLead({
        name: form.elements.name.value,
        email: form.elements.email.value,
        city: form.elements.city.value,
        kind: "respond",
        subject: ad.title
      })

      openSheet([
        el("h2", { id: "sheet-title", text: "Готово" }),
        notice(message),
        el("button", { class: "btn btn--wine btn--block", type: "button", onClick: closeSheet }, "Закрыть")
      ])
    } catch (failure) {
      button.disabled = false
      button.before(error(failure.messages))
    }
  }
}

// ---------- статьи ----------

async function articlesScreen() {
  const list = el("div", { class: "form" })

  render(banner("Статьи", "Как готовить питомца к передержке"), list)
  loadArticles(list)
}

async function loadArticles(list, { append = false } = {}) {
  const tail = el("div", { class: "form" }, skeletons(append ? 1 : 3))
  append ? list.append(tail) : list.replaceChildren(tail)

  try {
    const { articles, meta } = await api.articles({ page: state.page })

    const cards = articles.map((article) =>
      el("button", { class: "card", type: "button", onClick: () => go(`article/${article.id}`) }, [
        article.tag && el("span", { class: "tag", text: article.tag }),
        el("h3", { text: article.title }),
        article.excerpt && el("p", { text: article.excerpt }),
        article.read_time && el("p", { class: "card__meta", text: article.read_time })
      ])
    )

    const left = meta.total - meta.page * meta.per_page
    const more = left > 0 && el("button", {
      class: "btn btn--block",
      type: "button",
      onClick: (event) => { event.currentTarget.remove(); state.page += 1; loadArticles(list, { append: true }) }
    }, `Показать ещё · осталось ${left}`)

    tail.replaceWith(...cards, ...(more ? [ more ] : []))
  } catch (failure) {
    tail.replaceWith(error(failure.messages))
  }
}

async function articleScreen(id) {
  render(backButton("articles"), ...skeletons(2))

  try {
    const { article } = await api.article(id)

    render(
      backButton("articles"),
      banner(article.title, [ article.tag, article.read_time ].filter(Boolean).join(" · ")),
      el("section", { class: "card article-body" },
        article.paragraphs.length
          ? article.paragraphs.map((text) => el("p", { text }))
          : [ el("p", { text: article.excerpt || "Текст статьи скоро появится." }) ])
    )
  } catch (failure) {
    render(backButton("articles"), error(failure.messages))
  }
}

// ---------- профиль ----------

async function profileScreen() {
  render(banner("Профиль", "Данные питомца и ваши объявления"), ...skeletons(2))

  try {
    const [ { profile }, { ads } ] = await Promise.all([ api.profile(), api.myAds() ])

    // Имя и город подставляем из VK, пока человек не вписал свои.
    const fromVk = vk.suggestedProfile()
    const prefilled = fromVk && vk.untouchedName(profile.name)

    const form = el("form", { class: "form", onSubmit: save }, [
      field("Имя", "name", { value: prefilled ? fromVk.name : profile.name, placeholder: "Анна Петрова" }),
      field("Город", "city", { value: profile.city || (prefilled ? fromVk.city : ""), placeholder: "Москва" }),
      field("Контакт для связи", "email", { value: profile.email, placeholder: "anna@mail.ru" }),
      field("Питомец", "pet_name", { value: profile.pet_name, placeholder: "Барсик" }),
      field("Возраст питомца", "pet_age", { value: profile.pet_age, placeholder: "3 года" }),
      prefilled && el("p", { class: "muted", text: "Имя и город подставлены из вашей страницы ВКонтакте — поправьте, если нужно." }),
      el("button", { class: "btn btn--wine", type: "submit" }, "Сохранить")
    ])

    render(
      banner("Профиль", profile.pet_caption || "Расскажите о питомце"),
      vkCard(),
      el("section", { class: "card card--flat" }, form),
      el("section", { class: "banner" }, [
        el("h1", { text: "Мои объявления" }),
        el("p", { text: ads.length ? `Всего: ${ads.length}` : "Пока ни одного" })
      ]),
      el("button", { class: "btn btn--block", type: "button", onClick: newAdSheet }, "Добавить карточку"),
      ...ads.map(myAdCard)
    )

    async function save(event) {
      event.preventDefault()
      const button = form.querySelector("button[type=submit]")
      button.disabled = true
      form.querySelectorAll(".error, .notice").forEach((node) => node.remove())

      try {
        await api.updateProfile({
          name: form.elements.name.value,
          city: form.elements.city.value,
          email: form.elements.email.value,
          pet_name: form.elements.pet_name.value,
          pet_age: form.elements.pet_age.value
        })
        button.before(notice("Профиль сохранён"))
      } catch (failure) {
        button.before(error(failure.messages))
      } finally {
        button.disabled = false
      }
    }
  } catch (failure) {
    render(
      banner("Профиль"),
      error(failure.messages),
      failure.status === 401 && el("p", { class: "muted", text: "Откройте приложение внутри VK — профиль привязан к вашей странице." })
    )
  }
}

// Карточка «кто вошёл»: аватарка и имя берутся у ВКонтакте, вводить их не нужно.
function vkCard() {
  const user = vk.vkUser()
  if (!user) return null

  const photo = vk.avatarUrl()
  const letters = el("span", { class: "who__photo who__photo--letters", text: vk.initials() })

  // Картинку показываем сразу, а инициалы — только если она не загрузилась.
  const avatar = photo
    ? el("img", { class: "who__photo", src: photo, alt: "", onError: () => avatar.replaceWith(letters) })
    : letters

  return el("section", { class: "card card--who" }, [
    avatar,
    el("div", {}, [
      el("h3", { text: [ user.first_name, user.last_name ].filter(Boolean).join(" ") }),
      el("p", { class: "card__meta", text: "Вход через ВКонтакте — пароль не нужен" })
    ])
  ])
}

function myAdCard(ad) {
  return el("article", { class: "card" }, [
    el("span", { class: "tag", text: ad.status_label }),
    el("h3", { text: ad.title }),
    ad.description && el("p", { text: ad.description }),
    el("p", { class: "card__meta", text: ad.published_label }),
    el("button", {
      class: "btn",
      type: "button",
      onClick: async () => {
        await api.deleteAd(ad.id)
        profileScreen()
      }
    }, "Удалить")
  ])
}

function newAdSheet() {
  const kinds = el("select", { name: "kind" }, KINDS.slice(1).map((kind) => el("option", { value: kind }, kind)))

  const form = el("form", { class: "form", onSubmit: submit }, [
    el("h2", { id: "sheet-title", text: "Новое объявление" }),
    field("Заголовок", "title", { placeholder: "Барсик, 4 года" }),
    el("label", { class: "field" }, [ el("span", { text: "Вид питомца" }), kinds ]),
    field("Город", "city", { placeholder: "Москва" }),
    field("Сроки", "period", { placeholder: "12–26 июня" }),
    field("Цена", "price", { placeholder: "700 ₽ / день" }),
    field("Описание", "description", { rows: 4, placeholder: "Спокойный, привит, ест сухой корм." }),
    el("button", { class: "btn btn--wine btn--block", type: "submit" }, "Сохранить черновик")
  ])

  openSheet(form)
  form.elements.title.focus()

  async function submit(event) {
    event.preventDefault()
    const button = form.querySelector("button[type=submit]")
    button.disabled = true
    form.querySelectorAll(".error").forEach((node) => node.remove())

    try {
      await api.createAd({
        title: form.elements.title.value,
        kind: kinds.value,
        city: form.elements.city.value,
        period: form.elements.period.value,
        price: form.elements.price.value,
        description: form.elements.description.value
      })
      closeSheet()
      profileScreen()
    } catch (failure) {
      button.disabled = false
      button.before(error(failure.messages))
    }
  }
}

// ---------- поддержка ----------

async function supportScreen() {
  render(banner("Поддержка", "Отвечаем в среднем за 15 минут"), ...skeletons(2))

  try {
    const { channels, faq, topics } = await api.support()

    render(
      banner("Поддержка", "Отвечаем в среднем за 15 минут"),
      ...channels.map((channel) =>
        el("article", { class: "card" }, [
          el("h3", { text: channel.title }),
          channel.description && el("p", { text: channel.description }),
          el("p", { class: "card__meta", text: [ channel.value, channel.availability ].filter(Boolean).join(" · ") })
        ])
      ),
      el("button", { class: "btn btn--wine btn--block", type: "button", onClick: () => ticketSheet(topics) }, "Написать нам"),
      el("section", { class: "banner" }, [ el("h1", { text: "Частые вопросы" }) ]),
      ...faq.map((item) => {
        const answer = el("p", { text: item.answer, hidden: true })
        return el("article", { class: "card card--flat" }, [
          el("button", {
            class: "btn btn--block",
            type: "button",
            onClick: () => { answer.hidden = !answer.hidden }
          }, item.question),
          answer
        ])
      })
    )
  } catch (failure) {
    render(banner("Поддержка"), error(failure.messages))
  }
}

function ticketSheet(topics) {
  const select = el("select", { name: "topic" }, topics.map((topic) => el("option", { value: topic }, topic)))
  const counter = el("p", { class: "muted", text: "Ещё 20 символов" })

  const message = field("Сообщение", "message", { rows: 5, placeholder: "Что случилось?" })
  message.querySelector("textarea").addEventListener("input", (event) => {
    const length = event.target.value.trim().length
    counter.textContent = length >= 20 ? `${length} символов` : `Ещё ${20 - length} символов`
  })

  const form = el("form", { class: "form", onSubmit: submit }, [
    el("h2", { id: "sheet-title", text: "Написать нам" }),
    el("label", { class: "field" }, [ el("span", { text: "Тема обращения" }), select ]),
    field("Имя", "name", { placeholder: "Анна" }),
    field("E-mail для ответа", "email", { type: "email", placeholder: "you@mail.ru" }),
    message,
    counter,
    el("button", { class: "btn btn--wine btn--block", type: "submit" }, "Отправить обращение")
  ])

  openSheet(form)
  form.elements.name.focus()

  async function submit(event) {
    event.preventDefault()
    const button = form.querySelector("button[type=submit]")
    button.disabled = true
    form.querySelectorAll(".error").forEach((node) => node.remove())

    try {
      const ticket = await api.createTicket({
        name: form.elements.name.value,
        email: form.elements.email.value,
        topic: select.value,
        message: form.elements.message.value
      })

      openSheet([
        el("h2", { id: "sheet-title", text: `Обращение ${ticket.reference} принято` }),
        notice(`Ответ придёт на ${ticket.email}. Тема: ${ticket.topic}.`),
        el("button", { class: "btn btn--wine btn--block", type: "button", onClick: closeSheet }, "Закрыть")
      ])
    } catch (failure) {
      button.disabled = false
      button.before(error(failure.messages))
    }
  }
}

// ---------- маршруты ----------

const ROUTES = {
  ads: adsScreen,
  articles: articlesScreen,
  profile: profileScreen,
  support: supportScreen
}

function go(route) {
  location.hash = route
}

function route() {
  return (location.hash.replace(/^#/, "") || "ads").split("/")[0]
}

function open() {
  const [ name, id ] = (location.hash.replace(/^#/, "") || "ads").split("/")

  closeSheet()
  tabbar.querySelectorAll(".tab").forEach((tab) => {
    tab.toggleAttribute("aria-current", tab.dataset.route === name)
    if (tab.dataset.route === name) tab.setAttribute("aria-current", "page")
  })

  // Чтение статьи и карточка объявления открываются поверх списка и не сбрасывают
  // его: со «Назад» человек возвращается туда же, где был.
  if (name === "article" && id) return articleScreen(id)
  if (name === "ad" && id) return adScreen(id)

  state.page = 1
  ;(ROUTES[name] || adsScreen)()
}

tabbar.addEventListener("click", (event) => {
  const tab = event.target.closest(".tab")
  if (tab) go(tab.dataset.route)
})

window.addEventListener("hashchange", open)

// ---------- запуск ----------

// Экран рисуем сразу, не дожидаясь ВКонтакте: мост может и не ответить.
// Когда данные придут, дополняем шапку и, если открыт профиль, перерисуем его.
function start() {
  open()

  vk.connect({
    onAppearance: (mode) => document.body.classList.toggle("vk-dark", mode === "dark")
  }).then((user) => {
    if (!user) return

    if (user.first_name) topbarNote.textContent = `Привет, ${user.first_name}!`
    if (route() === "profile") profileScreen()
  })
}

start()
