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
  #   ## Заголовок    — коралловая полоса раздела во всю ширину
  #   @@ Заголовок    — плашка с заливкой: заголовок и текст внутри
  #   @ Заголовок     — панель с заголовком сбоку, содержимое рядом
  #   ### Заголовок   — колонка: рамка с заголовком внутри
  #   #### Заголовок  — колонка: салатовая плашка-заголовок над содержимым
  #   ! Текст         — салатовая плашка с крупной мыслью
  #   + Текст         — салатовая плашка с обычным текстом
  #   - пункт         — пункты-«пилюли»
  #   ---             — конец ряда
  #   обычный абзац   — плашка с текстом
  #   ~ cat           — рисунок у блока, отдельной строкой внутри блока
  #   ~ coral         — цвет плашки, если он не совпадает с чередованием
  #
  # Идущие подряд колонки встают в один ряд. У панелей и плашек с заливкой
  # цвет чередуется салатовый — коралловый, как в макете.
  COLUMN_MARKERS = [ [ "@@ ", "filled" ], [ "#### ", "pill" ],
                     [ "### ", "inline" ], [ "@ ", "aside" ] ].freeze
  TONED_STYLES = %w[filled aside].freeze

  # В макете рисунки расставлены вручную: у одной статьи кот выглядывает из
  # первой плашки, у другой руки держат салатовые плашки. Поэтому картинку
  # блока называют прямо в тексте — строкой «~ cat» внутри блока. Там же
  # задают цвет, если в макете он выбивается из чередования.
  ARTS = %w[cat plus minus hand hand-right].freeze
  TONES = %w[lime coral].freeze
  MARKS = (ARTS + TONES).freeze

  def layout
    state = { rows: [], row: nil, column: nil, panels: 0 }
    body_paragraphs.each { |chunk| add_chunk(state, chunk) }
    state[:rows]
  end

  private

  def add_chunk(state, chunk)
    chunk, art, tone = take_marks(chunk)
    marker = COLUMN_MARKERS.find { |prefix, _| chunk.start_with?(prefix) }

    if chunk == "---"
      close_row(state)
    elsif marker
      open_column(state, chunk.delete_prefix(marker.first).strip, marker.last, art, tone)
    elsif chunk.start_with?("## ")
      close_row(state)
      state[:rows] << { kind: "section", text: chunk.delete_prefix("## ").strip }
    elsif chunk.start_with?("! ")
      close_row(state)
      state[:rows] << { kind: "highlight", text: chunk.delete_prefix("! ").strip }
    elsif chunk.start_with?("+ ")
      add_block(state, { kind: "plate", tone: "lime", art: art, text: chunk.delete_prefix("+ ").strip },
                own_column: true)
    elsif chunk.start_with?("- ")
      add_block(state, { kind: "list", items: chunk.split("\n").map { |line| line.sub(/\A-\s*/, "").strip } })
    else
      add_block(state, { kind: "plate", art: art, text: chunk })
    end
  end

  # Строки вида «~ cat» из текста убираем, а сами пометки отдаём блоку.
  def take_marks(chunk)
    marks = []

    lines = chunk.split("\n").reject do |line|
      token = line.strip[/\A~\s*([a-z-]+)\z/, 1]
      marks << token if MARKS.include?(token)
    end

    [ lines.join("\n").strip, (marks & ARTS).first, (marks & TONES).first ]
  end

  def close_row(state)
    state[:row] = nil
    state[:column] = nil
  end

  def open_column(state, title, style, art = nil, tone = nil)
    if TONED_STYLES.include?(style)
      state[:panels] += 1
      tone ||= state[:panels].odd? ? "lime" : "coral"
    else
      tone = nil
    end

    state[:column] = { title: title, style: style, tone: tone, art: art, blocks: [] }
    place_column(state, state[:column])
  end

  def place_column(state, column)
    if state[:row]
      state[:row][:columns] << column
    else
      state[:row] = { kind: "row", columns: [ column ] }
      state[:rows] << state[:row]
    end
  end

  def add_block(state, block, own_column: false)
    return state[:column][:blocks] << block if state[:column]

    if own_column
      place_column(state, { title: nil, style: "plain", tone: nil, art: nil, blocks: [ block ] })
    else
      close_row(state)
      state[:rows] << block
    end
  end
end
