class FaqItem < ApplicationRecord
  validates :question, :answer, presence: true

  scope :ordered, -> { order(:position, :id) }
end
