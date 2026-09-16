class Ad < ApplicationRecord
  KINDS = [ "Кошка", "Собака", "Грызун", "Птица" ].freeze
  ALL_KINDS = "Все".freeze
  STATUS_LABELS = { "published" => "Активно", "draft" => "Черновик" }.freeze

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
    text.to_s.mb_chars.downcase.to_s.squish
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

  private

  def build_search_text
    self.search_text = self.class.normalize([ title, kind, city, period, description ].join(" "))
  end
end
