module Magnetik
  class CreditCard < ActiveRecord::Base
    # Associations:
    belongs_to :customer, polymorphic: true

    # Validations:
    validates :customer, presence: true
    validates :last_4_digits, presence: true
    validates :exp_month, presence: true
    validates :exp_year, presence: true
    validates :brand, presence: true
    validates :last_validated_at, presence: true

    def requires_revalidation?
      return false if Magnetik.validation_interval.nil?

      Magnetik.validation_interval.ago > last_validated_at
    end
  end
end
