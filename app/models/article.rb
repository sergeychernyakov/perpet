class Article < ApplicationRecord
  validates :title, presence: true

  scope :ordered, -> { order(:position, :id) }

  # В макете у статьи несколько меток, поэтому поле хранит их через запятую.
  def tag_list
    tag.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  # Статья для мини-приложения VK.
  def as_api
    {
      id: id,
      title: title,
      tag: tag,
      tags: tag_list,
      read_time: read_time,
      excerpt: excerpt,
      paragraphs: paragraphs
    }
  end

  def paragraphs
    body.to_s.split(/\n{2,}/).map(&:strip).reject(&:blank?)
  end

  # На странице статьи лид — это excerpt, поэтому первый абзац текста,
  # если он его повторяет, показывать второй раз незачем.
  def body_paragraphs
    paragraphs.reject { |paragraph| paragraph == excerpt.to_s.strip }
  end
end
