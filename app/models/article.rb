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
end
