class Ad < ApplicationRecord
  KINDS = [ "Кошка", "Собака", "Грызун", "Птица" ].freeze
  ALL_KINDS = "Все".freeze
  STATUS_LABELS = { "published" => "Активно", "draft" => "Черновик" }.freeze
  DEFAULT_ICON = "shape-04.svg".freeze
  ICONS = %w[shape-03.svg shape-04.svg shape-17.svg shape-18.svg shape-19.svg].freeze

  include HasPhoto

  belongs_to :profile, optional: true

  validates :title, presence: true
  validates :kind, presence: true, inclusion: { in: KINDS }

  before_save :build_search_text

  scope :published, -> { where(status: "published") }
  scope :drafts, -> { where(status: "draft") }
  scope :recent, -> { order(Arel.sql("published_on IS NULL"), published_on: :desc, id: :asc) }

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

  def published_label
    published_on ? "Опубликовано #{I18n.l(published_on, format: :long)}" : "Не опубликовано"
  end

  # Карточка для мини-приложения VK.
  def as_api
    {
      id: id,
      title: title,
      kind: kind,
      city: city,
      period: period,
      price: price,
      description: description,
      icon: icon_name,
      status: status,
      status_label: status_label,
      meta: meta,
      published_on: published_on,
      published_label: published_label,
      photo_url: photo_url,
      mine: profile_id.present?
    }
  end

  private

  def build_search_text
    self.search_text = self.class.normalize([ title, kind, city, period, description ].join(" "))
  end
end
