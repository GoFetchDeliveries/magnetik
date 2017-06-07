require 'magnetik/engine'
require 'magnetik/rails/routes'

require 'responders'

module Magnetik
  extend ActiveSupport::Autoload

  autoload :ActsAsMagnetikCustomer, 'magnetik/acts_as_magnetik_customer'

  # Method to authenticate a user:
  mattr_accessor :authentication_method
  @@authentication_method = nil

  # Method to retrieve the current authenticated user:
  mattr_accessor :current_user_method
  @@current_user_method = nil

  # Maximum length of card names:
  mattr_accessor :max_name_length
  @@max_name_length = 255

  # Time between card validations via pre-auth:
  mattr_accessor :validation_interval
  @@validation_interval = 3.months

  mattr_accessor :logger
  def self.logger
    @@logger ||= Logger.new(STDOUT)
  end

  def self.logger=(logger)
    @@logger = logger
  end

  private

  # Default way to setup Magnetik:
  def self.setup
    yield self
  end
end

module ActiveRecord
  class Base
    include Magnetik::ActsAsMagnetikCustomer
  end
end
