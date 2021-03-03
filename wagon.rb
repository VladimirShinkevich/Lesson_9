# frozen_string_literal: true

require_relative 'company'
require_relative 'validate'

class Wagon
  include Company
  include Validation
  attr_reader :wagon_type

  def initialize(wagon_type)
    @wagon_type = wagon_type
  end

  def validate!
    raise ArgumentError, 'Неправильный тип вагона' unless %i[passenger cargo].include? wagon_type
  end
end
