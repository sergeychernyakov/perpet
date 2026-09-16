import { Controller } from "@hotwired/stimulus"

// Карточки появляются через animation-timeline: view(). Этого не умеют
// Safari на iOS младше 26 и старые Android-браузеры — там анимации
// отыгрывают сразу при загрузке, и при прокрутке ничего не происходит.
// В таких браузерах ставим их на паузу и включаем, когда блок входит в экран.
const REVEALED = [
  ".banner", ".advantage", ".note", ".promo", ".pie", ".pie span",
  ".benefit", ".fact", ".step", ".benefits__title img", ".quote img", ".important__art img",
  ".ad", ".article", ".my-ad", ".channel", ".faq", ".faq__item", ".ticket"
].join(", ")

export default class extends Controller {
  connect() {
    if (CSS.supports("animation-timeline", "view()")) return

    document.documentElement.classList.add("no-view-timeline")

    this.onScroll = this.onScroll.bind(this)
    this.observer = new IntersectionObserver(this.reveal.bind(this), { rootMargin: "0px 0px -10% 0px" })
    this.element.querySelectorAll(REVEALED).forEach((node) => this.observer.observe(node))

    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.onScroll()
  }

  disconnect() {
    this.observer?.disconnect()
    window.removeEventListener("scroll", this.onScroll)
  }

  reveal(entries) {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return

      entry.target.classList.add("in-view")
      this.observer.unobserve(entry.target)
    })
  }

  // Тень под шапкой тоже держится на прокрутке — повторяем её вручную.
  onScroll() {
    document.querySelector(".header")?.classList.toggle("is-scrolled", window.scrollY > 8)
  }
}
