class Article < ApplicationRecord
  validates :title, presence: true

  scope :ordered, -> { order(:position, :id) }

  # Статья для мини-приложения VK.
  def as_api
    {
      id: id,
      title: title,
      tag: tag,
      read_time: read_time,
      excerpt: excerpt,
      paragraphs: paragraphs
    }
  end

  def paragraphs
    body.to_s.split(/\n{2,}/).map(&:strip).reject(&:blank?)
  end
end
