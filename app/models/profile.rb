class Profile < ApplicationRecord
  include HasPhoto

  belongs_to :user
  has_many :ads, dependent: :nullify

  validates :name, presence: { message: "Укажите имя" }

  def pet_caption
    [ pet_name, pet_age ].compact_blank.join(", ")
  end

  # Заполняем только пустое: то, что человек вписал сам, важнее данных из VK.
  def fill_missing_from_vk(person)
    changes = {}
    changes[:name] = person.full_name if person.full_name.present? && (name.blank? || name.match?(/\Avk-\d+\z/))
    changes[:city] = person.city if city.blank? && person.city.present?
    changes[:email] = person.email if email.blank? && person.email.present?

    update(changes) if changes.any?
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
      pet_caption: pet_caption,
      photo_url: photo_url
    }
  end
end
