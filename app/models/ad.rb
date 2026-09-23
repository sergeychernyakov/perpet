class Ad < ApplicationRecord
  # Виды из макета 2.0: там на карточках стоят «Кот», «Собака», «Кролик».
  KINDS = [ "Кот", "Собака", "Кролик", "Грызун", "Птица" ].freeze
  ALL_KINDS = "Все".freeze
  # В макете объявления разделены на два раздела: карточки питомцев, которым
  # ищут временный дом, и карточки ситтеров, которые готовы его дать.
  PET = "pet".freeze
  SITTER = "sitter".freeze
  ROLES = { PET => "питомцев", SITTER => "ситтеров" }.freeze
  STATUS_LABELS = { "published" => "Активно", "draft" => "Черновик" }.freeze
  DEFAULT_ICON = "shape-04.svg".freeze
  ICONS = %w[shape-03.svg shape-04.svg shape-17.svg shape-18.svg shape-19.svg].freeze

  include HasPhoto

  belongs_to :profile, optional: true

  validates :title, presence: true
  validates :role, inclusion: { in: ROLES.keys }
  validates :kind, presence: true, inclusion: { in: KINDS }, if: :pet?

  before_save :build_search_text

  scope :published, -> { where(status: "published") }
  scope :drafts, -> { where(status: "draft") }
  scope :recent, -> { order(Arel.sql("published_on IS NULL"), published_on: :desc, id: :asc) }

  scope :of_role, ->(role) { where(role: ROLES.key?(role) ? role : PET) }

  scope :of_kind, ->(kind) {
    kind.blank? || kind == ALL_KINDS ? all : where(kind: kind)
  }

  # SQLite приводит к нижнему регистру только латиницу, поэтому ищем
  # по заранее подготовленному полю search_text.
  scope :search, ->(query) {
    query.blank? ? all : where("search_text LIKE ?", "%#{normalize(query)}%")
  }

  def self.normalize(text)
    text.to_s.downcase.squish
  end

  def icon_name
    icon.presence || DEFAULT_ICON
  end

  def status_label
    STATUS_LABELS.fetch(status, status)
  end

  def meta
    [ city, period ].compact_blank.join(" · ")
  end

  def pet? = role != SITTER
  def sitter? = role == SITTER

  # Текст карточки из макета: строки «Ключ: значение» одна под другой.
  def card_lines
    pairs = if sitter?
      [ [ "Возраст", age ], [ "Место", city ], [ "Деятельность", activity ], [ "О себе", description ] ]
    else
      [ [ "Возраст", age ], [ "Место", city ], [ "Порода", breed ], [ "Важно", description ] ]
    end

    pairs.filter_map { |label, value| "#{label}: #{value}" if value.present? }
  end

  # Метки под карточкой: вид питомца, город и сроки.
  def card_tags
    [ (kind if pet?), city, period ].compact_blank
  end

  # Кнопка ведёт на карточку хозяина питомца или самого ситтера.
  def owner_label
    sitter? ? "Профиль" : "Хозяин"
  end

  def published_label
    published_on ? "Опубликовано #{I18n.l(published_on, format: :long)}" : "Не опубликовано"
  end

  # Карточка для мини-приложения VK.
  def as_api
    {
      id: id,
      title: title,
      kind: kind,
      role: role,
      age: age,
      breed: breed,
      activity: activity,
      city: city,
      period: period,
      price: price,
      description: description,
      icon: icon_name,
      status: status,
      status_label: status_label,
      meta: meta,
      card_lines: card_lines,
      card_tags: card_tags,
      owner_label: owner_label,
      owner_id: profile_id,
      published_on: published_on,
      published_label: published_label,
      photo_url: photo_url
    }
  end

  private

  def build_search_text
    self.search_text = self.class.normalize([ title, kind, breed, activity, city, period, description ].join(" "))
  end
end
