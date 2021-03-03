# frozen_string_literal: true

require_relative 'company'
require_relative 'instance_counter'
require_relative 'validate'

class Train
  include Company
  include InstanceCounter
  include Validation
  attr_reader :speed, :current_station, :route, :number, :train_type, :wagons

  FORMAT = /^[\w\d][\w\d][\w\d]-?[\w\d][\w\d]$/i.freeze

  @@trains = []

  def self.find(number)
    @@trains.select { |train| train.number == number }
  end

  private

  attr_writer :speed, :current_station, :route, :wagons

  public

  def initialize(number, train_type)
    @number = number
    @train_type = train_type
    @wagons = []
    @speed = 0
    @@trains << self
    register_instance
    validate!
  end

  def go(speed)
    self.speed += speed
  end

  def stop
    @speed = 0
  end

  def add_wagon(wagon)
    @wagons << wagon if @speed.zero? && (wagon.wagon_type == train_type)
  end

  def delete_wagon
    return if @wagons.empty?

    @wagons.pop if @speed.zero?
  end

  def add_train_to_route(route)
    @route = route
    @current_station = route.starting_station
  end

  def next_station
    return if @current_station == @end_station

    station_index = route.show_route.index(@current_station)
    @current_station = route.show_route[station_index + 1]
  end

  def prev_station
    return if @current_station >= route.starting_station

    station_index = route.show_route.index(@current_station)
    @current_station = route.show_route[station_index - 1]
  end

  def train_moving_next
    return unless next_station

    @current_station.train_send(self)
    @current_station = next_station
    @current_station.train_arrived(self)
  end

  def train_moving_prev
    return unless prev_station

    @current_station.train_send(self)
    @current_station = prev_station
    @current_station.train_arrived(self)
  end

  def across_wagon_to_train(&block)
    wagons.each_with_index(&block) if block_given?
  end

  def validate!
    raise ArgumentError, 'Неправильный формат номера поезда' if @number !~ FORMAT
  end
end
