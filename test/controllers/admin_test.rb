require "test_helper"

class AdminTest < ActionDispatch::IntegrationTest
  test "гостя отправляет на вход" do
    get admin_root_path

    assert_redirected_to new_user_session_path
  end

  test "обычный пользователь в админку не попадает" do
    sign_in_member

    get admin_root_path

    assert_redirected_to root_path
    assert_equal "Раздел доступен только администраторам", flash[:alert]
  end

  test "администратор видит сводку" do
    sign_in_admin
    Article.create!(title: "Статья", position: 1)

    get admin_root_path

    assert_response :success
    assert_select ".admin__card", minimum: 5
  end

  test "все страницы админки открываются" do
    sign_in_admin
    article = Article.create!(title: "Статья", position: 1)
    faq = FaqItem.create!(question: "Как это работает?", answer: "Просто.", position: 1)
    channel = SupportChannel.create!(title: "Телефон", value: "+7 963 574-79-20", position: 1)
    ad = Ad.create!(title: "Мурзик", kind: "Кошка", status: "published")

    [ admin_root_path,
      admin_ads_path, new_admin_ad_path, edit_admin_ad_path(ad),
      admin_articles_path, new_admin_article_path, edit_admin_article_path(article),
      admin_faq_items_path, new_admin_faq_item_path, edit_admin_faq_item_path(faq),
      admin_support_channels_path, new_admin_support_channel_path, edit_admin_support_channel_path(channel),
      admin_support_tickets_path, admin_leads_path ].each do |path|
      get path
      assert_response :success, "#{path} не открылась"
    end
  end

  test "пустые формы админки показывают ошибки" do
    sign_in_admin

    { admin_articles_path => { article: { title: "" } },
      admin_faq_items_path => { faq_item: { question: "" } },
      admin_support_channels_path => { support_channel: { title: "" } },
      admin_ads_path => { ad: { title: "" } } }.each do |path, params|
      post path, params: params
      assert_response :unprocessable_entity, "#{path} не показала ошибку"
      assert_select ".errors li", minimum: 1
    end
  end

  test "длинные списки в админке разбиты на страницы" do
    sign_in_admin
    30.times { |index| Lead.create!(name: "Гость #{index}", email: "guest#{index}@mail.ru", kind: "join") }

    get admin_leads_path
    assert_response :success
    assert_select ".admin__table tbody tr", Admin::BaseController::PER_PAGE
    assert_select ".pager__page", minimum: 2

    get admin_leads_path, params: { page: 2 }
    assert_response :success
    assert_select ".admin__table tbody tr", 30 - Admin::BaseController::PER_PAGE
  end

  test "администратор создаёт объявление" do
    sign_in_admin

    assert_difference -> { Ad.count }, 1 do
      post admin_ads_path, params: { ad: { title: "Мурзик, 2 года", kind: "Кошка", city: "Москва",
                                           period: "1–5 июля", price: "500 ₽ / день",
                                           description: "Спокойный кот", status: "published" } }
    end

    assert_redirected_to admin_ads_path
    assert_equal "Мурзик, 2 года", Ad.last.title
  end

  test "объявление с чужим видом питомца не сохраняется" do
    sign_in_admin

    assert_no_difference -> { Ad.count } do
      post admin_ads_path, params: { ad: { title: "Дракоша", kind: "Дракон" } }
    end

    assert_response :unprocessable_entity
  end

  test "администратор редактирует и удаляет статью" do
    sign_in_admin
    article = Article.create!(title: "Старое название", position: 1)

    patch admin_article_path(article), params: { article: { title: "Новое название" } }
    assert_redirected_to admin_articles_path
    assert_equal "Новое название", article.reload.title

    assert_difference -> { Article.count }, -1 do
      delete admin_article_path(article)
    end
  end

  test "администратор видит обращения и заявки" do
    sign_in_admin
    SupportTicket.create!(name: "Анна", email: "anna@mail.ru", topic: "Передержка",
                          message: "Питомца некуда деть на выходные, помогите.")
    Lead.create!(name: "Сергей", email: "sergey@mail.ru", kind: "join")

    get admin_support_tickets_path
    assert_response :success
    assert_select ".admin__table td", /anna@mail\.ru/

    get admin_leads_path
    assert_response :success
    assert_select ".admin__table td", /sergey@mail\.ru/
  end
end
