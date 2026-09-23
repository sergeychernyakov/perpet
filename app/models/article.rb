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
      layout: layout
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

  # Текст статьи набирают в админке обычным текстом, пустая строка делит блоки:
  #
  #   ## Заголовок   — коралловая полоса раздела во всю ширину
  #   ! Текст        — салатовая плашка с крупной мыслью
  #   + Текст        — салатовая плашка с обычным текстом
  #   ### Заголовок  — колонка: плашка с заголовком и тем, что идёт под ней
  #   - пункт        — пункты-«пилюли»
  #   ---            — конец ряда колонок
  #   обычный абзац  — плашка с текстом
  #
  # Идущие подряд колонки встают в один ряд. Ряд из одной колонки макет
  # раскладывает как панель с заголовком сбоку и пункты рядом.
  def layout
    rows = []
    row = nil
    column = nil
    panels = 0

    body_paragraphs.each do |chunk|
      case chunk
      when "---"
        row = column = nil
      when /\A## /
        row = column = nil
        rows << { kind: "section", text: chunk.delete_prefix("## ").strip }
      when /\A! /
        row = column = nil
        rows << { kind: "highlight", text: chunk.delete_prefix("! ").strip }
      when /\A\+ /
        block = { kind: "plate", tone: "lime", text: chunk.delete_prefix("+ ").strip }
        column ? column[:blocks] << block : rows << block
      when /\A### /
        panels += 1
        column = { title: chunk.delete_prefix("### ").strip,
                   tone: panels.odd? ? "lime" : "coral", blocks: [] }
        if row
          row[:columns] << column
        else
          row = { kind: "row", columns: [ column ] }
          rows << row
        end
      when /\A- /
        block = { kind: "list", items: chunk.split("\n").map { |line| line.sub(/\A-\s*/, "").strip } }
        column ? column[:blocks] << block : rows << block
      else
        block = { kind: "plate", text: chunk }
        column ? column[:blocks] << block : rows << block
      end
    end

    rows
  end
end
