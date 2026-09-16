class Profile < ApplicationRecord
  belongs_to :user
  has_many :ads, dependent: :nullify

  validates :name, presence: { message: "Укажите имя" }

  def pet_caption
    [ pet_name, pet_age ].compact_blank.join(", ")
  end

  # Профиль для мини-приложения VK.
  def as_api
    {
      id: id,
      name: name,
      city: city,
      email: email,
      pet_name: pet_name,
      pet_age: pet_age,
      pet_caption: pet_caption
    }
  end
end
