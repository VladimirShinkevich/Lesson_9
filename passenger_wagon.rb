# frozen_string_literal: true

require_relative 'validate'
require_relative 'wagon'

class PassengerWagon < Wagon
  include Validation

  attr_reader :free_places, :occupied_places, :places

  private

  attr_writer :places, :free_places, :occupied_places

  public

  def initialize(wagon_type = :passenger, places)
    super wagon_type
    @places = places
    @occupied_places = 0
    @free_places = places
    validate!
  end

  def take_place(wagon_places)
    self.occupied_places += wagon_places
    self.free_places = places - occupied_places
  end

  private

  def validate!
    super
    raise ArgumentError, 'Неправильно введенное значение введите целое число' if places.class != Integer
    raise ArgumentError, 'Количество мест не может быть отрицательным' if places <= 0
    raise ArgumentError, 'Свободных мест нет!' if occupied_places == places
  end
end
