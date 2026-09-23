class Article < ApplicationRecord
  validates :title, presence: true

  scope :ordered, -> { order(:position, :id) }
  # Читать целиком можно только те статьи, у которых есть текст: остальные
  # карточки в списке — анонсы будущих тем, ссылками они не становятся.
  scope :readable, -> { where.not(body: [ nil, "" ]) }

  # В макете у статьи несколько меток, поэтому поле хранит их через запятую.
  def tag_list
    tag.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  def readable?
    body.present?
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
      readable: readable?,
      paragraphs: paragraphs,
      blocks: blocks
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

  # Текст статьи набирают в админке обычным текстом: пустая строка делит
  # абзацы, «## » в начале — раздел, «### » — подзаголовок внутри раздела,
  # строки с «- » — список.
  def blocks
    body_paragraphs.map do |chunk|
      if chunk.start_with?("### ")
        { kind: "subtitle", text: chunk.delete_prefix("### ").strip }
      elsif chunk.start_with?("## ")
        { kind: "title", text: chunk.delete_prefix("## ").strip }
      elsif chunk.start_with?("- ")
        { kind: "list", items: chunk.split("\n").map { |line| line.sub(/\A-\s*/, "").strip } }
      else
        { kind: "text", text: chunk }
      end
    end
  end
end
