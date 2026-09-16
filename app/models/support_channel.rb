class SupportChannel < ApplicationRecord
  validates :title, :value, presence: true

  scope :ordered, -> { order(:position, :id) }
end
