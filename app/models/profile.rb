class Profile < ApplicationRecord
  has_many :ads, dependent: :nullify

  validates :name, presence: true

  # Пока в сервисе нет регистрации, профиль один — демонстрационный.
  def self.current
    first
  end

  def pet_caption
    [ pet_name, pet_age ].compact_blank.join(", ")
  end
end
