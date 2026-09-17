import { api, ApiError, apiBase } from "./api.js"
import { el, field, skeletons, notice, error } from "./ui.js"
import * as vk from "./vk.js"
import { photoField } from "./photo.js"

const screen = document.getElementById("screen")
const menu = document.getElementById("menu")
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
  return el("section", { class: "banner ads__head" }, [
    el("h1", { class: "banner__title", text: title }),
    note && el("p", { class: "ads__found", text: note })
  ])
}

// Заголовок-разделитель с круглой кнопкой справа — как на сайте.
function heading(title, onClick, icon = "shape-12.svg") {
  return el("section", { class: "banner" }, [
    el("h2", { class: "banner__title", text: title }),
    onClick && el("button", { class: "round-btn", type: "button", onClick, title }, [
      el("img", { src: `assets/${icon}`, alt: "" })
    ])
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

// ---------- главная ----------

// Оформление главной приходит из того же источника, что и на сайте,
// чтобы тексты и картинки не расходились.
let content = null

async function loadContent() {
  if (!content) content = await api.content()
  return content
}

// Карточка промо и шага: разметка и доли — те же, что в макете сайта.
const JUSTIFY = { center: "center", right: "flex-end", left: "flex-start" }

function promoCard(promo, css = "promo") {
  const art = el("img", { class: "promo__art", src: promo.icon, alt: "" })
  art.style.cssText = `left: ${promo.art_left}; top: ${promo.art_top}; ` +
    `width: ${promo.art_width}; aspect-ratio: ${promo.art_ratio}; transform: ${promo.art_transform};`

  const title = el("h3", { class: "promo__title", text: promo.title })
  if (promo.title_width) title.style.width = promo.title_width

  const body = el("div", { class: "promo__body" }, [
    title,
    el("p", { class: "promo__text", text: promo.text }),
    el("div", { class: "promo__actions" }, [
      el("button", { class: "promo__arrow", type: "button", title: promo.cta, onClick: () => go(promo.route) }, [
        el("img", { src: "assets/shape-11.svg", alt: "" })
      ]),
      el("button", { class: "promo__cta", type: "button", onClick: () => go(promo.route) }, promo.cta)
    ])
  ])
  body.style.cssText = `left: ${promo.text_left}; width: ${promo.text_width}; text-align: ${promo.align};`
  body.querySelector(".promo__actions").style.justifyContent = JUSTIFY[promo.align] || "flex-start"

  return el("article", { class: css }, [ art, body ])
}

async function homeScreen() {
  render(...skeletons(3))

  let data
  try {
    data = await loadContent()
  } catch (failure) {
    return render(banner("PERPET"), error(failure.messages || "Не удалось загрузить"))
  }

  const HERO_LEAD = "Команда PERPET уже долгое время работает над преобразованием системы передержки " +
    "животных. Мы — первые на рынке, кто сможет помочь Вам в трудную минуту с наименьшими затратами. " +
    "Perpet — не просто компания, а целая система, которая обьединяет людей вокруг общей проблемы, " +
    "а также помогает ее решить без лишнего беспокойства."
  const HERO_JOIN = "Если вы хотите узнать больше о передержке с нашей помощью, то присоединяйтесь."

  const join = () => go("ads")

  // Широкая обложка: та же разметка и те же доли, что в макете сайта.
  const heroWide = el("section", { class: "hero hero--wide" }, [
    el("img", { class: "hero__cat", src: "assets/hero-21.svg", alt: "" }),
    el("img", { class: "hero__paw", src: "assets/hero-22.svg", alt: "" }),
    el("img", { class: "hero__hand", src: "assets/hero-19.svg", alt: "" }),
    el("img", { class: "hero__hand-back", src: "assets/hero-20.svg", alt: "" }),
    ...[ "r1", "r2", "r3", "l1", "l2", "l3" ].map((side, index) =>
      el("img", { class: `hero__whisker hero__whisker--${side}`, src: `assets/hero-${23 + index}.svg`, alt: "" })),
    el("span", { class: "hero__eye hero__eye--top" }),
    el("span", { class: "hero__eye hero__eye--bottom" }),
    el("div", { class: "hero__body" }, [
      el("h1", { class: "hero__title", text: "PERPET" }),
      el("p", { class: "hero__text", text: HERO_LEAD }),
      el("p", { class: "hero__text hero__text--right", text: HERO_JOIN }),
      el("div", { class: "hero__actions" }, [
        el("button", { class: "hero__arrow", type: "button", title: "Присоединиться", onClick: join }, [
          el("img", { src: "assets/shape-11.svg", alt: "" })
        ]),
        el("button", { class: "hero__cta", type: "button", onClick: join }, "Присоединиться")
      ])
    ])
  ])

  // Узкая обложка макета — её показывает та же медиазапрос-логика сайта.
  const heroNarrow = el("section", { class: "hero hero--narrow" }, [
    el("h1", { class: "hero__title", text: "PERPET" }),
    el("p", { class: "hero__text", text: HERO_LEAD }),
    el("div", { class: "hero__strip" }, [
      el("img", { class: "hero__strip-cat", src: "assets/hero-21.svg", alt: "" }),
      el("img", { class: "hero__strip-hand", src: "assets/hero-19.svg", alt: "" })
    ]),
    el("p", { class: "hero__text", text: HERO_JOIN }),
    el("button", { class: "btn btn--block", type: "button", onClick: join }, "Присоединиться")
  ])

  const advantages = el("div", { class: "advantages" }, data.advantages.map((item) =>
    el("div", { class: "advantage" }, [
      el("img", { src: item.icon, alt: "" }),
      el("p", { text: item.text })
    ])
  ))

  const pie = el("div", { class: "stat" }, [
    el("div", { class: "stat__plate" }, [
      el("h3", { class: "stat__title", text: "Почему нас выбирают?" }),
      el("img", { class: "stat__pie stat__pie--minor", src: "assets/pie-pink.svg", alt: "" }),
      el("img", { class: "stat__pie stat__pie--major", src: "assets/pie-cream.svg", alt: "" }),
      el("span", { class: "stat__value stat__value--minor", text: "37.2%" }),
      el("span", { class: "stat__value stat__value--major", text: "62.8%" }),
      el("span", { class: "stat__leader stat__leader--minor" }),
      el("span", { class: "stat__leader stat__leader--major" }),
      el("p", { class: "stat__note stat__note--minor", text: "Столько людей не пользуются услугами передержки, но смогут начать с PERPET." }),
      el("p", { class: "stat__note stat__note--major", text: "А столько уже пользуются, но всегда могут обратиться к PERPET в экстренный момент." })
    ])
  ])

  const note = el("section", { class: "note" }, [
    el("p", { text: "Оставьте питомцев в надежных руках, не откладывайте важное и доверьте нам помощь о мохнатых друзьях. Вы всегда можете обратиться за помощью или с отзывом или вопросом о нашей работе." })
  ])

  const important = el("section", { class: "important" }, [
    el("img", { class: "important__art important__art--pink", src: "assets/vazhno-pink.svg", alt: "" }),
    el("img", { class: "important__art important__art--cream", src: "assets/vazhno-cream.svg", alt: "" }),
    el("div", { class: "important__body" }, [
      el("h2", { class: "important__title", text: "ВАЖНО" }),
      el("p", { text: "Перед использованием наших услуг и перед регистрацией на сайте и в приложении настоятельно просим ознакомиться с нашей документацией. Это обезопасит вас и ваших питомцев и поможет нам для открытого и доверительного сотрудничества с нашими любимыми пользователями." }),
      el("p", { text: "Ознакомьтесь с информацией ниже, которая содержит правила содержания и передачи животных, которые помогут в спорной ситуации и обезопасят вас и других пользователей." }),
      el("div", { class: "important__actions" }, [
        el("a", { class: "btn important__download", href: apiBase + "/perpet-pravila.txt", target: "_blank", rel: "noreferrer" }, "Скачать PDF"),
        el("button", { class: "important__arrow", type: "button", title: "Поддержка", onClick: () => go("support") }, [
          el("img", { src: "assets/shape-11.svg", alt: "" })
        ]),
        el("button", { class: "important__support btn", type: "button", onClick: () => go("support") }, "Поддержка")
      ])
    ])
  ])

  render(heroWide, heroNarrow,
         heading("Нам доверяют, узнай почему", () => document.getElementById("why")?.scrollIntoView({ behavior: "smooth" })),
         el("div", { class: "why", id: "why" }, [ advantages, pie ]),
         heading("О чем мы?", () => go("about"), "shape-20.svg"),
         note,
         el("div", { class: "promos" }, data.promos.map((promo) => promoCard(promo))),
         important)
}

// ---------- о нас ----------

async function aboutScreen() {
  render(...skeletons(3))

  let data
  try {
    data = await loadContent()
  } catch (failure) {
    return render(banner("Знакомство с нами"), error(failure.messages || "Не удалось загрузить"))
  }

  const problem = el("section", { class: "note note--lime" }, [
    el("h2", { class: "problem__title", text: "Проблема" }),
    el("p", { text: "Сейчас людей, которые берут себе домой питомцев становится все больше. К сожалению, часто несмотря на призыв ответственно подходить к вопросу в особенности в плане финансов может не всегда выполняться. Это не должно стать проблемой ни для питомцев ни для их хозяев, так как каждый из нас может попасть в трудную ситуацию, когда питомца приходится оставлять на некоторое время." })
  ])

  const benefits = el("div", { class: "advantages" }, data.benefits.map((item) =>
    el("div", { class: "advantage" }, [
      el("img", { src: item.icon, alt: "" }),
      el("p", { text: item.text })
    ])
  ))

  const quote = el("section", { class: "quote" }, [
    el("p", { text: "Питомцы — наше отражение, которое должно быть передано в хорошие руки." })
  ])

  render(banner("Знакомство с нами"),
         problem,
         heading("Наши преимущества"),
         benefits,
         heading("Передержка с Perpet"),
         el("div", { class: "promos" }, data.steps.map(promoCard)),
         quote,
         el("nav", { class: "more" }, [
           el("button", { class: "btn", type: "button", onClick: () => go("home") }, "На главную")
         ]))
}

// ---------- бренд-бук ----------

async function brandScreen() {
  render(...skeletons(3))

  let data
  try {
    data = await loadContent()
  } catch (failure) {
    return render(banner("Brand book"), error(failure.messages || "Не удалось загрузить"))
  }

  const brand = data.brand

  const palette = el("section", { class: "palette" }, brand.swatches.map((hex) =>
    el("div", { class: "palette__chip", style: `background: ${hex}` },
      el("span", { class: `palette__hex${[ "#BCE29B", "#F8F3E0" ].includes(hex) ? " palette__hex--dark" : ""}`, text: hex }))
  ))

  const facets = el("section", { class: "facets" }, brand.facets.flatMap((facet) => [
    el("h3", { class: "facets__title", text: facet.title }),
    el("p", { class: "facets__text", text: facet.text })
  ]))

  const values = el("section", { class: "values" }, [
    el("h2", { class: "values__title", text: "Ценности" }),
    ...brand.values.map((value) => el("p", { class: "values__item" }, [
      el("span", { class: "values__name", text: `${value.title}: ` }),
      document.createTextNode(value.text)
    ]))
  ])

  const merch = el("section", { class: "note" }, [
    el("h2", { class: "problem__title", text: "Наш мерч" }),
    el("p", { text: brand.merch })
  ])

  render(banner("Стиль бренда"),
         palette,
         heading("Суть бренда"),
         facets, values,
         merch,
         el("nav", { class: "more" }, [
           el("button", { class: "btn", type: "button", onClick: () => go("home") }, "На главную")
         ]))
}

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
  }, [ input, el("button", { class: "btn btn--coral", type: "submit" }, "Найти") ])

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
      onClick: (event) => showMore(event, () => loadAds(list, { append: true }))
    }, `Показать ещё · осталось ${left}`)

    tail.replaceWith(...ads.map(adCard), ...(more ? [ more ] : []))
  } catch (failure) {
    tail.replaceWith(error(failure.messages))
  }
}

function adCard(ad) {
  return el("article", { class: "card" }, [
    ad.photo_url && el("img", { class: "card__photo", src: apiBase + ad.photo_url, alt: ad.title, loading: "lazy" }),
    el("span", { class: "tag", text: ad.kind }),
    el("h3", { text: ad.title }),
    ad.meta && el("p", { class: "card__meta", text: ad.meta }),
    ad.description && el("p", { text: ad.description }),
    el("div", { class: "card__foot" }, [
      el("span", { class: "price", text: ad.price || "цена по договорённости" }),
      el("div", { class: "card__buttons" }, [
        vk.bridge() && el("button", { class: "btn", type: "button", onClick: (event) => share(event, ad) }, "Поделиться"),
        el("button", { class: "btn btn--coral", type: "button", onClick: () => respondSheet(ad) }, "Откликнуться")
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
            el("button", { class: "btn btn--coral", type: "button", onClick: () => respondSheet(ad) }, "Откликнуться")
          ])
        ])
      ])
    )
  } catch (failure) {
    render(backButton("ads"), error(failure.messages))
  }
}

function respondSheet(ad) {
  // Внутри ВКонтакте имя и город уже известны, а почту можно попросить у VK —
  // тогда человеку не нужно печатать ничего.
  const fromVk = vk.suggestedProfile()

  const fillEmail = vk.bridge() && el("button", {
    class: "btn", type: "button", onClick: takeEmailFromVk
  }, "Взять почту из ВКонтакте")

  const form = el("form", { class: "form", onSubmit: submit }, [
    el("h2", { id: "sheet-title", text: "Отклик на объявление" }),
    el("p", { class: "muted", text: `Вы откликаетесь: ${ad.title}` }),
    field("Имя", "name", { value: fromVk?.name, placeholder: "Анна" }),
    field("E-mail", "email", { type: "email", placeholder: "you@mail.ru" }),
    fillEmail,
    field("Город", "city", { value: fromVk?.city, placeholder: "Москва" }),
    el("button", { class: "btn btn--coral btn--block", type: "submit" }, "Отправить")
  ])

  openSheet(form)
  form.elements[fromVk ? "email" : "name"].focus()

  async function takeEmailFromVk(event) {
    const button = event.currentTarget
    const label = button.textContent
    button.disabled = true

    try {
      const email = await vk.requestEmail()

      if (email) {
        form.elements.email.value = email
        button.remove()
      } else {
        button.textContent = label
      }
    } catch {
      // Человек отказался или VK не разрешил приложению спрашивать почту.
      button.textContent = "Не получилось — впишите вручную"
    } finally {
      button.disabled = false
    }
  }

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
        el("button", { class: "btn btn--coral btn--block", type: "button", onClick: closeSheet }, "Закрыть")
      ])
    } catch (failure) {
      button.disabled = false
      button.before(error(failure.messages))
    }
  }
}

// Пока едет следующая страница, кнопка остаётся на месте и честно говорит,
// что происходит: исчезнувшая кнопка выглядит как будто нажатие не сработало.
function showMore(event, load) {
  const button = event.currentTarget
  button.disabled = true
  button.classList.add("btn--loading")
  button.textContent = "Загружаем…"

  state.page += 1
  load().finally(() => button.remove())
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
        el("div", { class: "tags" }, (article.tags || (article.tag ? [ article.tag ] : []))
          .map((tag) => el("span", { class: "tag", text: tag }))),
        el("h3", { text: article.title }),
        article.excerpt && el("p", { text: article.excerpt }),
        article.read_time && el("p", { class: "card__meta", text: article.read_time })
      ])
    )

    const left = meta.total - meta.page * meta.per_page
    const more = left > 0 && el("button", {
      class: "btn btn--block",
      type: "button",
      onClick: (event) => showMore(event, () => loadArticles(list, { append: true }))
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
      banner(article.title, [ (article.tags || []).join(" · ") || article.tag, article.read_time ].filter(Boolean).join(" · ")),
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
      el("button", { class: "btn btn--coral", type: "submit" }, "Сохранить")
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
  const photo = photoField("Фотография питомца")

  const form = el("form", { class: "form", onSubmit: submit }, [
    el("h2", { id: "sheet-title", text: "Новое объявление" }),
    field("Заголовок", "title", { placeholder: "Барсик, 4 года" }),
    el("label", { class: "field" }, [ el("span", { text: "Вид питомца" }), kinds ]),
    field("Город", "city", { placeholder: "Москва" }),
    field("Сроки", "period", { placeholder: "12–26 июня" }),
    field("Цена", "price", { placeholder: "700 ₽ / день" }),
    field("Описание", "description", { rows: 4, placeholder: "Спокойный, привит, ест сухой корм." }),
    photo.field,
    el("button", { class: "btn btn--coral btn--block", type: "submit" }, "Сохранить черновик")
  ])

  openSheet(form)
  form.elements.title.focus()

  async function submit(event) {
    event.preventDefault()
    const button = form.querySelector("button[type=submit]")
    button.disabled = true
    form.querySelectorAll(".error").forEach((node) => node.remove())

    try {
      const data = new FormData()
      data.append("ad[title]", form.elements.title.value)
      data.append("ad[kind]", kinds.value)
      data.append("ad[city]", form.elements.city.value)
      data.append("ad[period]", form.elements.period.value)
      data.append("ad[price]", form.elements.price.value)
      data.append("ad[description]", form.elements.description.value)
      if (photo.file()) data.append("ad[photo]", photo.file())

      await api.createAdWithPhoto(data)
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
      el("button", { class: "btn btn--coral btn--block", type: "button", onClick: () => ticketSheet(topics) }, "Написать нам"),
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
    el("button", { class: "btn btn--coral btn--block", type: "submit" }, "Отправить обращение")
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
        el("button", { class: "btn btn--coral btn--block", type: "button", onClick: closeSheet }, "Закрыть")
      ])
    } catch (failure) {
      button.disabled = false
      button.before(error(failure.messages))
    }
  }
}

// ---------- маршруты ----------

const ROUTES = {
  home: homeScreen,
  about: aboutScreen,
  brand: brandScreen,
  ads: adsScreen,
  articles: articlesScreen,
  profile: profileScreen,
  support: supportScreen
}

function go(route) {
  location.hash = route
}

function route() {
  return (location.hash.replace(/^#/, "") || "home").split("/")[0]
}

function open() {
  const [ name, id ] = (location.hash.replace(/^#/, "") || "home").split("/")

  closeSheet()
  menu.dataset.open = "false"
  document.querySelectorAll(".nav__link").forEach((link) => {
    link.classList.toggle("nav__link--current", link.dataset.route === name)
  })

  // Чтение статьи и карточка объявления открываются поверх списка и не сбрасывают
  // его: со «Назад» человек возвращается туда же, где был.
  if (name === "article" && id) return articleScreen(id)
  if (name === "ad" && id) return adScreen(id)

  state.page = 1
  ;(ROUTES[name] || homeScreen)()
}

// Любая кнопка с data-route ведёт на свой экран: шапка, меню и подвал.
document.addEventListener("click", (event) => {
  const target = event.target.closest("[data-route]")
  if (target) go(target.dataset.route)
})

document.getElementById("burger").addEventListener("click", () => {
  menu.dataset.open = menu.dataset.open === "true" ? "false" : "true"
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

    if (route() === "profile") profileScreen()
  })
}

start()
