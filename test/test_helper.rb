ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def sign_in_admin
    sign_in User.create!(email: "admin-#{SecureRandom.hex(4)}@perpet.ru", password: "perpet123", role: :admin)
  end

  def sign_in_member(email: nil)
    sign_in User.create!(email: email || "user-#{SecureRandom.hex(4)}@mail.ru", password: "perpet123")
  end
end
