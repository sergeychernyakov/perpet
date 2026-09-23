require "test_helper"

class HasPhotoTest < ActiveSupport::TestCase
  # Однопиксельный PNG — самый маленький настоящий файл, какой можно приложить.
  PIXEL = Base64.decode64(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="
  )

  def attach(record, data: PIXEL, name: "pet.png", type: "image/png")
    record.photo.attach(io: StringIO.new(data), filename: name, content_type: type)
    record
  end

  test "объявление принимает картинку и отдаёт ссылку" do
    ad = attach(Ad.new(title: "Мурзик", kind: "Кот"))

    assert ad.save
    assert ad.photo.attached?
    assert_match %r{\A/rails/active_storage/}, ad.photo_url
    assert_equal ad.photo_url, ad.as_api[:photo_url]
  end

  test "без картинки ссылки нет" do
    ad = Ad.create!(title: "Мурзик", kind: "Кот")

    assert_nil ad.photo_url
    assert_nil ad.as_api[:photo_url]
  end

  test "не изображение отклоняется" do
    ad = attach(Ad.new(title: "Мурзик", kind: "Кот"),
                data: "вовсе не картинка", name: "doc.pdf", type: "application/pdf")

    assert_not ad.valid?
    assert_includes ad.error_messages.join(" "), "должно быть изображением"
  end

  test "слишком большой файл отклоняется" do
    ad = attach(Ad.new(title: "Мурзик", kind: "Кот"), data: "0" * (HasPhoto::MAX_BYTES + 1))

    assert_not ad.valid?
    assert_includes ad.error_messages.join(" "), "больше 3 МБ"
  end

  test "профиль тоже принимает фото питомца" do
    profile = User.create!(email: "photo@mail.ru", password: "perpet123").profile

    assert attach(profile).save
    assert_equal profile.photo_url, profile.as_api[:photo_url]
  end
end
