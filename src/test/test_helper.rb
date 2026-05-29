ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "rack/test"

module TestFileUploads
  def upload_fixture(name, mime_type)
    Rack::Test::UploadedFile.new(file_fixture(name), mime_type)
  end

  def attach_fixture(attachment, name, mime_type)
    file = file_fixture(name).open
    attachment.attach(io: file, filename: name, content_type: mime_type)
  ensure
    file&.close
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    include TestFileUploads
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include TestFileUploads
end
