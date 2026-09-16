class Profile < ApplicationRecord
  belongs_to :user
  has_many :ads, dependent: :nullify

  validates :name, presence: true

  def pet_caption
    [ pet_name, pet_age ].compact_blank.join(", ")
  end
end
