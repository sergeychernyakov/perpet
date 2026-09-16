# Фотография объявления или питомца.
#
# Картинку уменьшает браузер перед отправкой (upload_controller и его двойник
# в мини-приложении), поэтому сервер ничего не пережимает — на нём нет ни
# libvips, ни места под оригиналы. Предел стоит на случай, если файл придёт
# в обход интерфейса.
module HasPhoto
  extend ActiveSupport::Concern

  MAX_BYTES = 3.megabytes
  TYPES = %w[image/jpeg image/png image/webp].freeze

  included do
    has_one_attached :photo

    validate :photo_looks_like_picture
  end

  def photo_url
    return nil unless photo.attached?

    Rails.application.routes.url_helpers.rails_blob_path(photo, only_path: true)
  end

  private

  def photo_looks_like_picture
    return unless photo.attached?

    errors.add(:photo, "должно быть изображением JPEG, PNG или WebP") unless TYPES.include?(photo.blob.content_type)
    errors.add(:photo, "весит больше 3 МБ") if photo.blob.byte_size > MAX_BYTES
  end
end
