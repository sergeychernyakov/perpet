import { api, ApiError, apiBase } from "./api.js"
import { el, field, skeletons, notice, error } from "./ui.js"
import * as vk from "./vk.js"
import { photoField } from "./photo.js"

const screen = document.getElementById("screen")
const menu = document.getElementById("menu")
const sheet = document.getElementById("sheet")
const sheetBody = document.getElementById("sheet-body")

const state = { role: "pet", kind: "Все", query: "", page: 1 }
const KINDS = [ "Все", "Кот", "Собака", "Кролик", "Грызун", "Птица" ]
// Разделы объявлений из макета: карточки питомцев и карточки ситтеров.
const ROLES = [ [ "pet", "питомцев" ], [ "sitter", "ситтеров" ] ]

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

function scrollTo_(id) {
  document.getElementById(id)?.scrollIntoView({ behavior: "smooth" })
}

function statPlate() {
  return el("div", { class: "stat" }, [
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
}

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
  body.querySelector(".promo__actions").style.justifyContent =
    promo.justify || JUSTIFY[promo.align] || "flex-start"

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

  const pie = statPlate()

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
         heading("Нам доверяют, узнай почему", () => go("brand")),
         el("div", { class: "why", id: "why" }, [ advantages, pie ]),
         heading("О чем мы?", () => go("brand"), "shape-20.svg"),
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

  const join = () => go("ads")

  const head = el("section", { class: "about__head" }, [ el("h1", { text: "Знакомство с нами" }) ])

  const problem = el("section", { class: "problem" }, [
    el("img", { class: "problem__cat", src: "assets/ab-cat-big.svg", alt: "" }),
    el("img", { class: "problem__cat-inner", src: "assets/ab-cat-inner.svg", alt: "" }),
    el("div", { class: "problem__body" }, [
      el("h2", { class: "problem__title", text: "Проблема" }),
      el("p", { class: "problem__text", text: "Сейчас людей, которые берут себе домой питомцев становится все больше. К сожалению, часто несмотря на призыв ответственно подходить к вопросу в особенности в плане финансов может не всегда выполняться. Это не должно стать проблемой ни для питомцев ни для их хозяев, так как каждый из нас может попасть в трудную ситуацию, когда питомца приходится оставлять на некоторое время (отьезд, командировка и прочее). А самое трудное — это организовать его комфортное прибывание в чужих руках, не боясь финансовых трудностей." }),
      el("div", { class: "problem__actions" }, [
        el("button", { class: "problem__arrow", type: "button", title: "Присоединиться", onClick: join }, [
          el("img", { src: "assets/shape-11.svg", alt: "" })
        ]),
        el("button", { class: "problem__cta", type: "button", onClick: join }, "Присоединиться")
      ])
    ])
  ])

  const benefits = el("div", { class: "benefits" }, [
    el("div", { class: "benefits__title" }, [
      el("img", { src: "assets/ab-paw-wide2.svg", alt: "" }),
      el("h2", { text: "Наши преимущества" })
    ]),
    el("div", { class: "benefits__list" }, data.benefits.map((item) => {
      const icon = el("img", { src: item.icon, alt: "" })
      if (item.ratio) icon.style.aspectRatio = item.ratio

      return el("div", { class: "benefit" }, [ icon, el("p", { text: item.text }) ])
    }))
  ])

  const facts = el("div", { class: "facts" }, [
    el("div", { class: "fact" }, [
      el("img", { class: "fact__art fact__art--first", src: "assets/shape-42.svg", alt: "" }),
      el("p", { class: "fact__number", text: "66%" }),
      el("p", { class: "fact__text", text: "Российских семей имеют хотя бы одного пушистого члена семьи." })
    ]),
    el("div", { class: "fact" }, [
      el("img", { class: "fact__art fact__art--second", src: "assets/shape-43.svg", alt: "" }),
      el("p", { class: "fact__number", text: "93%" }),
      el("p", { class: "fact__text", text: "Владельцев официально заявляют, что считают своего питомца полноценным членом семьи, а не просто животным." })
    ])
  ])

  const quote = el("section", { class: "quote" }, [
    el("img", { class: "quote__paw", src: "assets/ab-paw-wide.svg", alt: "" }),
    el("img", { class: "quote__paw-cream", src: "assets/ab-paw-cream.svg", alt: "" }),
    el("span", { class: "quote__eye quote__eye--top" }),
    el("span", { class: "quote__eye quote__eye--bottom" }),
    el("p", { text: "Питомцы — наше отражение, которое должно быть передано в хорошие руки." })
  ])

  render(head, problem, benefits,
         heading("Хотите знать больше о ценностях компании?", () => scrollTo_("stats"), "shape-36.svg"),
         el("div", { class: "why", id: "stats" }, [ statPlate(), facts ]),
         heading("Передержка с Perpet", () => scrollTo_("flow"), "shape-37.svg"),
         el("div", { class: "flow", id: "flow" }, data.steps.map((step) => promoCard(step, "promo step"))),
         quote)
}

async function brandScreen() {
  render(...skeletons(3))

  let data
  try {
    data = await loadContent()
  } catch (failure) {
    return render(banner("Стиль бренда"), error(failure.messages || "Не удалось загрузить"))
  }

  const brand = data.brand
  const LIGHT = [ "#BCE29B", "#F8F3E0" ]

  const logoCard = el("section", { class: "brand__logo-card" }, [
    el("div", { class: "brand__marks" }, [
      el("span", { class: "brand__mark brand__mark--wide" }, [
        el("img", { class: "logo__shape", src: "assets/tb-logo-hand.svg", alt: "" }),
        el("img", { class: "logo__ear", src: "assets/tb-logo-ear.svg", alt: "" }),
        el("span", { class: "logo__eye logo__eye--left" }),
        el("span", { class: "logo__eye logo__eye--right" }),
        el("span", { class: "logo__name", text: "PERPET" })
      ]),
      el("span", { class: "brand__mark brand__mark--square" }, [
        el("img", { class: "icon-btn__shape", src: "assets/ab-paw-cream.svg", alt: "" }),
        el("span", { class: "icon-btn__eye icon-btn__eye--left" }),
        el("span", { class: "icon-btn__eye icon-btn__eye--right" })
      ])
    ]),
    el("p", { class: "brand__mark-label", text: "Логотип" })
  ])

  const palette = el("section", { class: "brand__palette" }, brand.swatches.map((hex) => {
    const swatch = el("div", { class: "brand__swatch" }, [
      el("span", { class: `brand__hex${LIGHT.includes(hex) ? " brand__hex--dark" : ""}`, text: hex })
    ])
    swatch.style.background = hex

    return swatch
  }))

  const art = el("section", { class: "brand__art" }, [
    el("img", { class: "brand__art-rabbit", src: "assets/brand-rabbit.svg", alt: "" }),
    el("span", { class: "brand__art-eye brand__art-eye--left" }),
    el("span", { class: "brand__art-eye brand__art-eye--right" }),
    el("img", { class: "brand__art-cat", src: "assets/hero-21.svg", alt: "" }),
    ...[ "l1", "l2", "l3", "r1", "r2", "r3" ].map((side) =>
      el("span", { class: `brand__whisker brand__whisker--${side}` })),
    el("img", { class: "brand__art-hand", src: "assets/promo-hand.svg", alt: "" }),
    el("img", { class: "brand__art-paw", src: "assets/promo-cat.svg", alt: "" })
  ])

  const pair = el("div", { class: "brand__pair" }, [
    el("article", { class: "brand__facets" }, brand.facets.flatMap((facet) => [
      el("h3", { class: "brand__facet-title", text: facet.title }),
      el("p", { class: "brand__facet-text", text: facet.text })
    ])),
    el("article", { class: "brand__values" }, [
      el("h2", { class: "brand__values-title", text: "Ценности" }),
      ...brand.values.map((value) => el("p", { class: "brand__value" }, [
        el("span", { class: "brand__value-name", text: `${value.title}:` }),
        document.createTextNode(value.text)
      ]))
    ])
  ])

  const merch = el("section", { class: "brand__merch" }, [
    el("div", {}, [
      el("p", { text: brand.merch }),
      el("button", { class: "btn btn--wide brand__cta", type: "button", onClick: () => go("support") }, "Хочу мерч")
    ]),
    el("div", { class: "brand__merch-art" }, [
      el("img", { src: "assets/shape-18.svg", alt: "" })
    ])
  ])

  render(banner("Стиль бренда"),
         logoCard, palette, art,
         heading("Суть бренда"), pair,
         heading("Наш мерч"), merch)
}

// ---------- объявления ----------

async function adsScreen() {
  const role = state.role || "pet"
  const label = ROLES.find(([ key ]) => key === role)[1]

  // Переключатель разделов: две плашки со стрелкой, как в макете.
  const tabs = el("nav", { class: "ads__switch" }, ROLES.map(([ key, name ], index) =>
    el("button", {
      class: `ads__tab${index ? " ads__tab--right" : ""}${key === role ? " ads__tab--current" : ""}`,
      type: "button",
      onClick: () => { state.role = key; state.kind = KINDS[0]; state.query = ""; state.page = 1; adsScreen() }
    }, [
      el("span", { class: "ads__tab-arrow" }, [ el("img", { src: "assets/shape-11.svg", alt: "" }) ]),
      el("span", { class: "ads__tab-label", text: `Обьявления ${name}` })
    ])))

  const input = el("input", {
    class: "form__input search__input", type: "search",
    placeholder: "кошка, Москва, июнь…", "aria-label": "Поиск"
  })
  input.value = state.query

  const filters = el("form", {
    class: "filters",
    onSubmit: (event) => { event.preventDefault(); state.query = input.value.trim(); state.page = 1; adsScreen() }
  }, [
    el("label", { class: "search" }, [ el("span", { class: "search__label", text: "Поиск" }), input ]),
    el("button", { class: "chip chip--filter chip--search", type: "submit" }, "Найти"),
    ...(role === "pet" ? KINDS.map((kind) => el("button", {
      class: `chip chip--filter${kind === state.kind ? " chip--current" : ""}`,
      type: "button",
      onClick: () => { state.kind = kind; state.page = 1; adsScreen() }
    }, kind)) : [])
  ])

  const list = el("div", { class: "ads", id: "ads-top" })
  const found = el("p", { class: "ads__found" })

  render(el("section", { class: "banner ads__head" }, [
    el("h1", { class: "banner__title", text: `Обьявления ${label}` }), found
  ]), tabs, filters, list)

  loadAds(list, { found })
}

// Страницы не подменяют друг друга, а дописываются в конец списка — так
// привычнее на телефоне и не теряется то, что человек уже просмотрел.
async function loadAds(list, { append = false, found = null } = {}) {
  const tail = el("div", { class: "ads" }, skeletons(append ? 1 : 3))
  append ? list.append(tail) : list.replaceChildren(tail)

  try {
    const { ads, meta } = await api.ads({
      role: state.role || "pet", kind: state.kind, q: state.query, page: state.page
    })

    if (found) found.textContent = `Найдено: ${meta.total} из ${meta.all ?? meta.total}`

    if (!ads.length) {
      tail.replaceWith(el("section", { class: "empty" }, [
        el("h3", { class: "empty__title", text: "Ничего не нашлось" }),
        el("p", { text: "Попробуйте другой вид питомца или очистите поиск." }),
        el("button", { class: "btn", type: "button", onClick: () => {
          state.kind = KINDS[0]; state.query = ""; state.page = 1; adsScreen()
        } }, "Сбросить фильтры")
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

// Карточка из макета: слева фото, справа строки «Ключ: значение»,
// кнопка на карточку хозяина и метки снизу.
function adCard(ad) {
  const photo = ad.photo_url
    ? el("img", { src: apiBase + ad.photo_url, alt: ad.title, loading: "lazy" })
    : el("img", { class: "ad__icon", src: `assets/${ad.icon}`, alt: "" })

  const owner = ad.owner_id
    ? el("a", { class: "ad__owner", href: `#person/${ad.owner_id}`, text: ad.owner_label })
    : el("button", { class: "ad__owner", type: "button", onClick: () => respondSheet(ad) }, "Откликнуться")

  return el("article", { class: "ad" }, [
    el("img", { class: "ad__paw", src: "assets/tb-logo-ear.svg", alt: "" }),
    el("h3", { class: "ad__title", text: ad.title }),
    el("div", { class: "ad__photo" }, [ photo ]),
    el("div", { class: "ad__body" }, [
      el("p", { class: "ad__text" }, (ad.card_lines || []).map((line) => el("span", { text: line }))),
      owner
    ]),
    el("div", { class: "ad__tags" }, (ad.card_tags || []).map((tag) =>
      el("span", { class: "tag tag--outline", text: tag })))
  ])
}

// Блок текста статьи: плашка, пункты-«пилюли» или текст без своей рамки.
function articleBlock(block, bare = false) {
  if (block.kind === "list") {
    return el("div", { class: "reading__pills" },
      block.items.map((item) => el("p", { class: "reading__pill", text: item })))
  }
  if (bare) return el("p", { class: "reading__text", text: block.text })

  return el("p", { class: `reading__plate${block.tone === "lime" ? " reading__plate--lime" : ""}`, text: block.text })
}

// Ряд статьи: полоса раздела, выделение или колонки с заголовками.
function articleRow(row) {
  if (row.kind === "section") {
    return el("section", { class: "banner" }, [ el("h2", { class: "banner__title", text: row.text }) ])
  }
  if (row.kind === "highlight") return el("p", { class: "reading__highlight", text: row.text })
  if (row.kind !== "row") return articleBlock(row)

  const style = row.columns[0].style
  const body = (column) => el("div", { class: "reading__col" }, column.blocks.map((b) => articleBlock(b)))

  // Плашка с заливкой: заголовок и текст внутри, во всю ширину.
  if (style === "filled") {
    return row.columns.map((column) => el("section", { class: `reading__filled reading__filled--${column.tone}` }, [
      el("h3", { class: "reading__filled-title", text: column.title }),
      ...column.blocks.map((block) => articleBlock(block, true))
    ]))
  }

  // Панель с заголовком сбоку и содержимое рядом.
  if (style === "aside" && row.columns.length === 1) {
    const column = row.columns[0]

    return el("div", { class: `reading__row reading__row--split reading__row--${column.tone}` }, [
      el("h3", { class: `reading__panel reading__panel--${column.tone}`, text: column.title }),
      body(column)
    ])
  }

  const grid = el("div", { class: "reading__row" }, row.columns.map((column) => {
    if (column.style === "inline") {
      return el("div", { class: "reading__frame" }, [
        el("h3", { class: "reading__frame-title", text: column.title }),
        ...column.blocks.map((block) => articleBlock(block, true))
      ])
    }

    return el("div", { class: "reading__column" }, [
      column.title && el("h3", { class: "reading__panel reading__panel--lime", text: column.title }),
      body(column)
    ])
  }))
  grid.style.setProperty("--cols", row.columns.length)

  return grid
}

// Карточка пользователя: кто стоит за объявлением.
async function personScreen(id) {
  render(...skeletons(2))

  let profile, ads
  try {
    ({ profile, ads } = await api.publicProfile(id))
  } catch (failure) {
    return render(backButton("ads"), error(failure.messages))
  }

  const photo = profile.photo_url
    ? el("img", { src: apiBase + profile.photo_url, alt: profile.name })
    : el("img", { class: "person__photo-icon", src: "assets/ab-paw-cream.svg", alt: "" })

  const person = el("div", { class: "person" }, [
    el("div", { class: "person__photo" }, [ photo ]),
    el("article", { class: "person__card" }, [
      el("h2", { class: "person__subtitle", text: "Информация о пользователе" }),
      el("p", { class: "person__lines" }, (profile.card_lines || []).map((line) => el("span", { text: line })))
    ]),
    el("div", { class: "person__side" }, [
      el("article", { class: "person__card person__card--short" }, [
        el("h2", { class: "person__subtitle", text: "Контакты" }),
        el("p", { class: "person__lines" }, (profile.contact_lines || []).map((line) => el("span", { text: line })))
      ]),
      el("a", { class: "person__card person__card--back", href: "#ads" }, [
        el("span", { class: "person__subtitle", text: "Вернуться к обьявлениям" }),
        el("span", { class: "person__arrow" }, [ el("img", { src: "assets/shape-11.svg", alt: "" }) ])
      ])
    ])
  ])

  render(banner("Карточка пользователя"), person,
         ...(ads.length ? [ heading("Обьявления пользователя"),
                            el("div", { class: "ads" }, ads.map(adCard)) ] : []))
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
  render(...skeletons(2))

  try {
    const { ad } = await api.ad(id)

    render(
      el("section", { class: "banner ads__head" }, [
        el("h1", { class: "banner__title", text: ad.title }),
        el("p", { class: "ads__found", text: [ ad.kind, ad.meta ].filter(Boolean).join(" · ") })
      ]),
      el("div", { class: "grid grid--cards" }, [ adCard(ad) ]),
      el("a", { class: "btn", href: "#ads", text: "Все обьявления" })
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

// Кот выглядывает из-за каждого второго блока — как в макете.
function articleCat() {
  return el("div", { class: "article__cat", "aria-hidden": "true" }, [
    el("img", { class: "article__cat-art", src: "assets/hero-21.svg", alt: "" }),
    ...[ "l1", "l2", "l3", "r1", "r2", "r3" ].map((side) =>
      el("span", { class: `article__whisker article__whisker--${side}` }))
  ])
}

// Ссылкой карточка становится, только если у статьи есть текст: остальные —
// анонсы будущих тем, открывать в них нечего.
function articleCard(article, index) {
  const href = `#article/${article.id}`
  const tags = article.tags || (article.tag ? [ article.tag ] : [])

  return el("article", { class: `article${index % 2 ? " article--mirror" : ""}` }, [
    index % 2 ? articleCat() : null,
    el("div", { class: "article__top" }, [
      el("h3", { class: "article__title" },
         article.readable ? [ el("a", { href, text: article.title }) ] : article.title),
      article.readable && el("a", { class: "article__arrow", href, title: `Читать «${article.title}»` }, [
        el("img", { src: "assets/shape-11.svg", alt: "" })
      ])
    ]),
    article.excerpt && el("p", { class: "article__text", text: article.excerpt }),
    el("div", { class: "article__tags" }, tags.map((tag) =>
      el("span", { class: "tag tag--outline", text: tag })))
  ])
}

async function articlesScreen() {
  const list = el("div", { class: "articles", id: "arts-top" })

  render(el("section", { class: "articles__head" }, [
    el("h1", { class: "articles__title", text: "Статьи" })
  ]), list)

  loadArticles(list)
}

async function loadArticles(list, { append = false } = {}) {
  const tail = el("div", { class: "articles" }, skeletons(append ? 1 : 3))
  append ? list.append(tail) : list.replaceChildren(tail)

  try {
    const { articles, meta } = await api.articles({ page: state.page })

    const offset = append ? list.querySelectorAll(".article").length : 0
    const cards = articles.map((article, index) => articleCard(article, offset + index))

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
  render(...skeletons(2))

  let article
  try {
    ({ article } = await api.article(id))
  } catch (failure) {
    return render(backButton("articles"), error(failure.messages))
  }

  // Статья приходит рядами плашек — та же раскладка, что на сайте.
  const reading = el("article", { class: "reading" }, [
    ...(article.layout || []).flatMap(articleRow),
    el("div", { class: "reading__actions" }, [
      el("a", { class: "btn", href: "#articles" }, "Все статьи"),
      el("button", { class: "btn btn--coral btn--wide", type: "button", onClick: () => go("ads") }, "Присоединиться")
    ])
  ])

  const more = el("div", { class: "articles" })

  render(banner(article.title), reading, more)

  // «Читать дальше» — те же блоки, что и в списке.
  try {
    const { articles } = await api.articles({ page: 1 })
    const rest = articles.filter((one) => one.readable && String(one.id) !== String(id)).slice(0, 2)
    if (rest.length) {
      more.replaceWith(el("section", { class: "banner" }, [
        el("h2", { class: "banner__title", text: "Читать дальше" })
      ]), el("div", { class: "articles" }, rest.map(articleCard)))
    }
  } catch {
    more.remove()
  }
}

// ---------- профиль ----------

async function profileScreen() {
  render(...skeletons(3))

  let profile
  try {
    ({ profile } = await api.profile())
  } catch (failure) {
    return render(
      banner("Ваш профиль"),
      error(failure.messages),
      failure.status === 401 && el("p", { class: "muted", text: "Откройте приложение внутри VK — профиль привязан к вашей странице." })
    )
  }

  const photo = profile.photo_url
    ? el("img", { src: apiBase + profile.photo_url, alt: profile.name })
    : el("img", { class: "person__photo-icon", src: "assets/ab-paw-cream.svg", alt: "" })

  const person = el("div", { class: "person" }, [
    el("div", { class: "person__photo" }, [ photo ]),
    el("article", { class: "person__card" }, [
      el("h2", { class: "person__subtitle", text: "Информация о пользователе" }),
      personLines(profile.card_lines, "Расскажите о себе — так вас узнают другие пользователи."),
      el("a", { class: "person__edit", href: "#profile-edit", text: "Изменить данные" })
    ]),
    el("div", { class: "person__side" }, [
      el("article", { class: "person__card person__card--short" }, [
        el("h2", { class: "person__subtitle", text: "Контакты" }),
        personLines(profile.contact_lines, "Телефон и почту видят те, кто откликается на карточку.")
      ]),
      el("a", { class: "person__card person__card--back", href: "#pets" }, [
        el("span", { class: "person__subtitle", text: "Ваши питомцы" }),
        el("span", { class: "person__arrow" }, [ el("img", { src: "assets/shape-11.svg", alt: "" }) ])
      ])
    ])
  ])

  render(banner("Ваш профиль"), person, addCards(), vkAccount())
}

function personLines(values, fallback) {
  const lines = values && values.length ? values : [ fallback ]

  return el("p", { class: "person__lines" }, lines.map((line) => el("span", { text: line })))
}

// Две плашки «Добавь карточку» и пояснение — они же на экране «Ваши питомцы».
function addCards() {
  const plate = (role, title, paw) =>
    el("a", { class: "profile__add", href: `#card/${role}` }, [
      el("span", { class: "profile__add-title", text: title }),
      el("span", { class: "person__arrow" }, [ el("img", { src: "assets/shape-11.svg", alt: "" }) ]),
      el("img", { class: "profile__add-paw", src: `assets/${paw}`, alt: "" })
    ])

  return el("div", { class: "profile__cards" }, [
    plate("sitter", "Добавь карточку ситтера", "tb-logo-ear.svg"),
    plate("pet", "Добавь карточку питомца", "ab-paw-cream.svg"),
    el("p", {
      class: "profile__note",
      text: "После заполнения профиля добавляйте карточки хозяина или питомца, " +
            "чтобы продолжать поддерживать питомцев и их хозяев."
    })
  ])
}

// «Изменить данные»: та же форма, что на сайте.
async function profileEditScreen() {
  render(...skeletons(2))

  let profile
  try {
    ({ profile } = await api.profile())
  } catch (failure) {
    return render(backButton("profile"), error(failure.messages))
  }

  // Имя и город подставляем из VK, пока человек не вписал свои.
  const fromVk = vk.suggestedProfile()
  const prefilled = fromVk && vk.untouchedName(profile.name)
  const photo = photoField("Добавьте ваше фото", {
    current: profile.photo_url && apiBase + profile.photo_url, plus: true
  })

  const input = (name, value, placeholder, required = false) =>
    el("label", { class: "card-form__field" }, [
      el("span", { class: "visually-hidden", text: placeholder }),
      el("input", { class: "form__input", name, value: value || "", placeholder, required: required || null })
    ])

  const about = el("textarea", { class: "card-form__area", name: "about", rows: 6 })
  about.value = profile.about || ""

  const form = el("form", { class: "card-form", onSubmit: save }, [
    el("div", { class: "card-form__fields" }, [
      input("name", prefilled ? fromVk.name : profile.name, "Имя*", true),
      input("age", profile.age, "Возраст"),
      input("activity", profile.activity, "Деятельность"),
      input("city", profile.city || (prefilled ? fromVk.city : ""), "Место")
    ]),
    el("label", { class: "card-form__plate card-form__plate--wide" }, [
      el("span", { class: "card-form__label", text: "Расскажите о себе" }),
      about
    ]),
    el("div", { class: "card-form__plate" }, [
      el("span", { class: "card-form__label", text: "Контакты" }),
      el("input", { class: "form__input", name: "phone", value: profile.phone || "", placeholder: "Телефон" }),
      el("input", { class: "form__input", name: "email", value: profile.email || "", placeholder: "Почта" })
    ]),
    el("div", { class: "card-form__plate card-form__plate--photo" }, [
      el("img", { class: "card-form__paw", src: "assets/tb-logo-ear.svg", alt: "" }), photo.field
    ]),
    el("div", { class: "card-form__actions" }, [
      el("button", { class: "btn btn--coral btn--wide", type: "submit" }, "Сохранить"),
      el("a", { class: "btn", href: "#profile" }, "Отмена")
    ])
  ])

  render(banner("Изменить данные"), form)

  async function save(event) {
    event.preventDefault()
    const button = form.querySelector("button[type=submit]")
    button.disabled = true
    form.querySelectorAll(".error, .notice").forEach((node) => node.remove())

    const fields = {
      name: form.elements.name.value,
      age: form.elements.age.value,
      activity: form.elements.activity.value,
      city: form.elements.city.value,
      about: about.value,
      phone: form.elements.phone.value,
      email: form.elements.email.value
    }

    try {
      const file = photo.file()

      if (file) {
        const data = new FormData()
        Object.entries(fields).forEach(([ key, value ]) => data.append(`profile[${key}]`, value))
        data.append("profile[photo]", file)
        await api.updateProfileWithPhoto(data)
      } else {
        await api.updateProfile(fields)
      }

      go("profile")
    } catch (failure) {
      button.disabled = false
      button.before(error(failure.messages))
    }
  }
}

// «Ваши питомцы»: заведённые карточки или «Упс!», если их ещё нет.
async function petsScreen() {
  render(...skeletons(2))

  let ads
  try {
    ({ ads } = await api.myAds())
  } catch (failure) {
    return render(banner("Ваши питомцы"), error(failure.messages))
  }

  const list = ads.length
    ? el("div", { class: "ads" }, ads.map(myAdCard))
    : el("section", { class: "oops" }, [
        el("h2", { class: "oops__title", text: "Упс!" }),
        el("p", { class: "oops__text", text: "Вы еще не заполнили ни одну карточку питомца" })
      ])

  render(banner("Ваши питомцы"), list, addCards())
}

function myAdCard(ad) {
  const photo = ad.photo_url
    ? el("img", { src: apiBase + ad.photo_url, alt: ad.title, loading: "lazy" })
    : el("img", { class: "ad__icon", src: `assets/${ad.icon}`, alt: "" })

  return el("article", { class: "ad" }, [
    el("img", { class: "ad__paw", src: "assets/tb-logo-ear.svg", alt: "" }),
    el("h3", { class: "ad__title", text: ad.title }),
    el("div", { class: "ad__photo" }, [ photo ]),
    el("div", { class: "ad__body" }, [
      el("p", { class: "ad__text" }, [
        ...(ad.card_lines || []).map((line) => el("span", { text: line })),
        el("span", { text: ad.published_label })
      ]),
      el("a", { class: "ad__owner", href: `#card/${ad.role}/${ad.id}`, text: "Изменить" })
    ]),
    el("div", { class: "ad__tags" }, [ ad.status_label, ...(ad.card_tags || []) ].map((tag) =>
      el("span", { class: "tag tag--outline", text: tag })))
  ])
}

// «Карточка питомца» и «Карточка временного хозяина» — одна форма на две роли.
async function cardScreen(role, id) {
  render(...skeletons(2))

  const sitter = role === "sitter"
  const title = sitter ? "Карточка временного хозяина" : "Карточка питомца"

  let ad = { role }
  try {
    if (id) {
      // Берём из своих карточек, а не из каталога: чужую так не открыть.
      const { ads } = await api.myAds()
      ad = ads.find((one) => String(one.id) === String(id)) || { role }
    } else if (sitter) {
      const { profile } = await api.profile()
      ad = { role, title: profile.name, age: profile.age, city: profile.city,
             activity: profile.activity, description: profile.about }
    }
  } catch (failure) {
    return render(backButton("pets"), error(failure.messages))
  }

  const photo = photoField(sitter ? "Добавьте ваше фото*" : "Добавьте фото питомца*",
                           { current: ad.photo_url && apiBase + ad.photo_url, plus: true })

  const input = (name, value, placeholder, required = false) =>
    el("label", { class: "card-form__field" }, [
      el("span", { class: "visually-hidden", text: placeholder }),
      el("input", { class: "form__input", name, value: value || "", placeholder, required: required || null })
    ])

  const kinds = el("select", { class: "form__input", name: "kind" }, [
    el("option", { value: "", disabled: true, selected: !ad.kind || null }, "Вид/порода*"),
    ...KINDS.slice(1).map((kind) => el("option", { value: kind, selected: kind === ad.kind || null }, kind))
  ])

  const fields = sitter
    ? [ input("title", ad.title, "Имя*", true), input("age", ad.age, "Возраст*"),
        input("activity", ad.activity, "Деятельность*"), input("city", ad.city, "Адрес*") ]
    : [ input("title", ad.title, "Кличка*", true),
        el("div", { class: "card-form__field card-form__field--pair" }, [
          el("span", { class: "visually-hidden", text: "Вид/порода*" }),
          kinds,
          el("input", { class: "form__input", name: "breed", value: ad.breed || "", placeholder: "Порода" })
        ]),
        input("age", ad.age, "Возраст*"), input("city", ad.city, "Адрес*") ]

  const about = el("textarea", { class: "card-form__area", name: "description", rows: 6 })
  about.value = ad.description || ""

  const form = el("form", { class: "card-form", onSubmit: save }, [
    el("div", { class: "card-form__fields" }, fields),
    el("label", { class: "card-form__plate card-form__plate--wide" }, [
      el("span", {
        class: "card-form__label",
        text: sitter ? "Укажите важную информацию о себе и почему решили стать ситтером*"
                     : "Укажите важную информацию о питомце*"
      }),
      about
    ]),
    el("label", { class: "card-form__plate" }, [
      el("span", { class: "card-form__label", text: "Укажите даты пребывания*" }),
      el("input", { class: "form__input", name: "period", value: ad.period || "", placeholder: "16.02 – 24.02" })
    ]),
    el("div", { class: "card-form__plate card-form__plate--photo" }, [
      el("img", { class: "card-form__paw", src: "assets/tb-logo-ear.svg", alt: "" }), photo.field
    ]),
    el("p", {
      class: "card-form__note",
      text: sitter ? "После заполнения карточки Ваш профиль отобразится у других пользователей."
                   : "После заполнения карточки питомца Ваш профиль станет виден другим пользователям."
    }),
    el("div", { class: "card-form__actions" }, [
      el("button", { class: "btn btn--coral btn--wide", type: "submit" }, "Сохранить"),
      el("a", { class: "btn", href: "#pets" }, "Отмена"),
      id && el("button", {
        class: "btn", type: "button",
        onClick: async () => { await api.deleteAd(id); go("pets") }
      }, "Удалить")
    ])
  ])

  render(banner(title), form)

  async function save(event) {
    event.preventDefault()
    const button = form.querySelector("button[type=submit]")
    button.disabled = true
    form.querySelectorAll(".error").forEach((node) => node.remove())

    const values = {
      role, title: form.elements.title.value, age: form.elements.age.value,
      city: form.elements.city.value, period: form.elements.period.value,
      description: about.value, status: "published"
    }
    if (sitter) {
      values.activity = form.elements.activity.value
    } else {
      values.kind = kinds.value
      values.breed = form.elements.breed.value
    }

    try {
      const file = photo.file()

      if (file) {
        const data = new FormData()
        Object.entries(values).forEach(([ key, value ]) => data.append(`ad[${key}]`, value ?? ""))
        data.append("ad[photo]", file)
        await api.createAdWithPhoto(data)
      } else if (id) {
        await api.updateAd(id, values)
      } else {
        await api.createAd(values)
      }

      go("pets")
    } catch (failure) {
      button.disabled = false
      button.before(error(failure.messages))
    }
  }
}

// Карточка «кто вошёл»: аватарка и имя берутся у ВКонтакте, вводить их не нужно.
function vkAccount() {
  const user = vk.vkUser()
  if (!user) return null

  const url = vk.avatarUrl()
  const letters = el("span", { class: "who__photo who__photo--letters", text: vk.initials() })
  const avatar = url
    ? el("img", { class: "who__photo", src: url, alt: "", onError: () => avatar.replaceWith(letters) })
    : letters

  return el("div", { class: "profile__account" }, [
    avatar,
    el("span", { text: [ user.first_name, user.last_name ].filter(Boolean).join(" ") }),
    el("span", { class: "profile__vk", text: "ВКонтакте привязан" })
  ])
}

// ---------- поддержка ----------

async function supportScreen() {
  render(...skeletons(3))

  let data
  try {
    data = await api.support()
  } catch (failure) {
    return render(banner("Поддержка"), error(failure.messages))
  }

  const head = el("section", { class: "support__head" }, [
    el("div", {}, [
      el("h1", { class: "support__title", text: "Поддержка" }),
      el("p", { class: "support__lead", text: "Отвечаем 24/7 по любым вопросам о передержке, объявлениях и документах. Обычно отвечаем за 15 минут." })
    ]),
    el("div", { class: "support__contacts" }, [
      el("a", { class: "support__contact", href: "tel:+79635747920", text: "+7 963 574-79-20" }),
      el("a", { class: "support__contact", href: "mailto:perpet@mail.ru", text: "perpet@mail.ru" })
    ])
  ])

  const channels = el("div", { class: "grid grid--cards" }, data.channels.map((channel) =>
    el("a", { class: "channel", href: channel.href, target: "_blank", rel: "noreferrer" }, [
      el("span", { class: "tag", text: channel.availability }),
      el("h3", { class: "channel__title", text: channel.title }),
      el("p", { class: "channel__text", text: channel.description }),
      el("span", { class: "channel__value", text: channel.value })
    ])
  ))

  const faq = el("section", { class: "faq" }, [
    el("h2", { class: "faq__title", text: "Частые вопросы" }),
    ...data.faq.map((item, index) => el("details", { class: "faq__item", open: index === 0 }, [
      el("summary", { class: "faq__question" }, [
        el("span", { text: item.question }),
        el("span", { class: "faq__sign" })
      ]),
      el("p", { class: "faq__answer", text: item.answer })
    ]))
  ])

  render(head, channels, faq, ticketSection(data.topics))
}

// Форма обращения — как на сайте, прямо на странице, а не карточкой поверх.
function ticketSection(topics) {
  const slot = el("div", { id: "ticket" })
  slot.append(ticketForm(topics, slot))

  return el("section", { class: "ticket" }, [
    el("div", {}, [
      el("h2", { class: "ticket__title", text: "Написать нам" }),
      el("p", { class: "ticket__lead", text: "Опишите ситуацию — чем подробнее, тем быстрее разберёмся. Если вопрос по конкретному объявлению, укажите его название." }),
      el("p", { class: "ticket__time", text: "Среднее время ответа — 15 минут, ночью до 2 часов." })
    ]),
    slot
  ])
}

function ticketForm(topics, slot) {
  const chips = topics.map((topic, index) => {
    const radio = el("input", { class: "visually-hidden", type: "radio", name: "topic", value: topic })
    radio.checked = index === 0

    return el("label", { class: "chip" }, [ radio, document.createTextNode(topic) ])
  })

  const hint = el("span", { class: "form__hint", text: "Ещё 20 символов" })
  const message = el("textarea", {
    class: "form__textarea", name: "message", rows: 5,
    placeholder: "Что случилось?", required: true, minlength: 20,
    onInput: (event) => {
      const length = event.target.value.trim().length
      hint.textContent = length >= 20 ? `${length} символов` : `Ещё ${20 - length} символов`
    }
  })

  const form = el("form", { class: "form", onSubmit: submit }, [
    el("div", {}, [
      el("span", { class: "form__label", text: "Тема обращения" }),
      el("div", { class: "chips" }, chips)
    ]),
    el("label", {}, [
      el("span", { class: "form__label", text: "Имя" }),
      el("input", { class: "form__input", name: "name", placeholder: "Анна", required: true, minlength: 2 })
    ]),
    el("label", {}, [
      el("span", { class: "form__label", text: "E-mail для ответа" }),
      el("input", { class: "form__input", type: "email", name: "email", placeholder: "you@mail.ru", required: true })
    ]),
    el("label", {}, [
      el("span", { class: "form__label", text: "Сообщение" }),
      message,
      hint
    ]),
    el("button", { class: "btn btn--coral", type: "submit" }, "Отправить обращение")
  ])

  return form

  async function submit(event) {
    event.preventDefault()
    const button = form.querySelector("button[type=submit]")
    button.disabled = true
    form.querySelectorAll(".form__error").forEach((node) => node.remove())

    try {
      const ticket = await api.createTicket({
        name: form.elements.name.value,
        email: form.elements.email.value,
        topic: form.querySelector("input[name=topic]:checked")?.value,
        message: form.elements.message.value
      })

      slot.replaceChildren(
        el("p", { class: "ticket__sent", text: `Обращение ${ticket.reference} принято` }),
        el("p", { class: "ticket__time", text: `Ответ придёт на ${ticket.email}. Тема: ${ticket.topic}.` })
      )
    } catch (failure) {
      button.disabled = false
      button.before(el("p", { class: "form__error", text: [].concat(failure.messages).join(". ") }))
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
  "profile-edit": profileEditScreen,
  pets: petsScreen,
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
  if (name === "person" && id) return personScreen(id)
  if (name === "ad" && id) return adScreen(id)
  if (name === "card") return cardScreen(id || "pet", (location.hash.split("/")[2]))

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
