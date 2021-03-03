# frozen_string_literal: true

require_relative 'validate'
require_relative 'wagon'

class CargoWagon < Wagon
  include Validation
  attr_reader :volume, :free_volume, :occupied_volume

  private

  attr_writer :volume, :free_volume, :occupied_volume

  public

  def initialize(wagon_type = :cargo, volume)
    super(wagon_type)
    @volume = volume
    @occupied_volume = 0
    @free_volume = volume
    validate!
  end

  def take_volume(wagon_volume)
    self.occupied_volume += wagon_volume
    self.free_volume = volume - occupied_volume
  end

  private

  def validate!
    super
    raise ArgumentError, 'Объём заполнен' if occupied_volume >= volume
    raise ArgumentError, 'Объём не может быть меньше 0 или равно 0' if volume <= 0
  end
end
