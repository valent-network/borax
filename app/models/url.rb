# frozen_string_literal: true

class Url < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :validation_helpers

  def validate
    super
    validates_presence %i[address status]
    validates_unique :address
    validates_format %r{\Ahttps?://}, :address, message: 'is not a valid URL'
  end
end
