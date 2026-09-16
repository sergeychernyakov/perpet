require "test_helper"

class AdTest < ActiveSupport::TestCase
  setup do
    @cat = Ad.create!(kind: "Кошка", title: "Барсик, 4 года", city: "Москва", period: "12–26 июня",
                      price: "700 ₽ / день", description: "Спокойный, привит.", status: "published",
                      published_on: Date.current)
    @dog = Ad.create!(kind: "Собака", title: "Тоша, 2 года", city: "Казань", period: "3–10 июля",
                      price: "1 200 ₽ / день", description: "Метис, любит прогулки.", status: "published",
                      published_on: Date.current - 1)
  end

  test "требует вид питомца из списка" do
    ad = Ad.new(title: "Без вида", kind: "Дракон")
    assert_not ad.valid?
    assert_includes ad.errors.attribute_names, :kind
  end

  test "фильтр по виду питомца" do
    assert_equal [ @cat ], Ad.of_kind("Кошка").to_a
    assert_equal 2, Ad.of_kind(Ad::ALL_KINDS).count
  end

  test "поиск не зависит от регистра и ищет по городу" do
    assert_equal [ @cat ], Ad.search("МОСКВА").to_a
    assert_equal [ @dog ], Ad.search("метис").to_a
    assert_empty Ad.search("попугай").to_a
  end

  test "мета собирается из города и срока" do
    assert_equal "Москва · 12–26 июня", @cat.meta
  end

  test "черновик показывается как черновик" do
    draft = Ad.create!(kind: "Кошка", title: "Новое объявление", status: "draft")

    assert_equal "Черновик", draft.status_label
    assert_equal "Не опубликовано", draft.published_label
    assert_equal [ @cat, @dog ], Ad.published.recent.to_a
  end
end
