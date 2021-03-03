# frozen_string_literal: true

require_relative 'instance_counter'
require_relative 'validate'

class Route
  include InstanceCounter
  include Validation
  attr_accessor :starting_station, :end_station, :intermediate_stations

  def initialize(starting_station, end_station)
    @starting_station = starting_station
    @end_station = end_station
    @intermediate_stations = []
    register_instance
    validate!
  end

  def add_intermediate_station(station)
    @intermediate_stations << station
  end

  def delete_intermediate_station(station)
    @intermediate_stations.delete(station)
  end

  def show_route
    [@starting_station, *@intermediate_stations, @end_station]
  end

  def validate!
    raise ArgumentError, 'Нет начальной станции' if @starting_station.class != Station
    raise ArgumentError, 'Нет конечной станции' if @end_station.class != Station
  end
end
