class Article < ApplicationRecord
  validates :title, presence: true

  scope :ordered, -> { order(:position, :id) }

  def paragraphs
    body.to_s.split(/\n{2,}/).map(&:strip).reject(&:blank?)
  end
end
