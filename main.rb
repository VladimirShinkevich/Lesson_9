# frozen_string_literal: true

require_relative 'station'
require_relative 'train'
require_relative 'route'
require_relative 'passenger_train'
require_relative 'cargo_train'
require_relative 'wagon'
require_relative 'passenger_wagon'
require_relative 'cargo_wagon'
require_relative 'menu'
require_relative 'instance_counter'
require_relative 'company'

class Menu
  include Company
  include InstanceCounter

  private

  attr_writer :trains, :stations, :routes

  public

  attr_reader :routes, :stations, :trains

  def initialize
    @stations = []
    @trains = []
    @routes = []
    @wagons = []
    @stop = false
  end

  def start_railway
    loop do
      if @stop
        puts 'Всего хорошего!!!'
        break
      else
        puts MAIN_MENU
        puts 'Введите действие (1 - 3): '
        choose = gets.chomp.to_i
        main_menu(choose)
      end
    end
  end

  private

  def main_menu(choose)
    case choose
    when 1 then create_object
    when 2 then perform_menu
    when 3 then info_menu
    when 4 then @stop = true
    end
  end

  def create_object
    puts CREATE_MENU
    choose = gets.chomp.to_i
    case choose
    when 1 then create_train
    when 2 then create_route
    when 3 then create_station
    end
  end

  def perform_menu
    puts TRAIN_MENU
    choose = gets.chomp.to_i
    case choose
    when 1 then trains_manage
    when 2 then routes_manage
    when 3 then wagons_manage
    end
  end

  def info_menu
    puts INFORMATION_MENU
    choose = gets.chomp.to_i
    case choose
    when 1 then info_train
    when 2 then info_route
    when 3 then info_station
    end
  end

  def info_train
    puts 'Информация о поездах'
    @trains.each_with_index do |train, index|
      puts "Индекс поезда: #{index}"
      puts "Номер поезда: #{train.number}"
      puts "Тип поезда: #{train.train_type}"
      puts "Маршрут: #{train.route.show_route.map(&:station_name)}"
      puts "Вагоны: #{train.wagons}"
    end
  end

  def info_route
    puts 'Информация о маршрутах'
    @routes.each_with_index do |route, index|
      puts "Индекс маршрута: #{index}"
      puts "Наименование маршрута: #{route.show_route.map(&:station_name)}"
    end
  end

  def info_station
    puts ''
    @stations.each do |station|
      puts "Название станции: #{station.station_name}"
      puts 'Информация о поездах на станции'
      if station.trains.empty?
        puts ''
      else
        station.across_train_on_station do |train, index|
          puts "#{index} #{train.number} #{train.train_type} #{train.wagons}"
        end
      end
    end
  end

  def trains_manage
    if @trains.empty?
      puts 'Нет доступных поездов!'
      create_train
    else
      @trains.each_with_index do |train, index|
        puts "Индекс поезда - #{index} (Номер поезда - #{train.number}, Тип поезда - #{train.train_type})"
      end
      puts 'Введите индекс поезда: '
      train_index = gets.chomp.to_i
      puts PERFORM_MENU
      puts 'Выберите действие (1 - 5): '
      choose = gets.chomp.to_i
      case choose
      when 1 then add_train_to_route(train_index)
      when 2 then add_wagons_to_train(train_index)
      when 3 then delete_train_wagons(train_index)
      when 4 then move_train_next_station(train_index)
      when 5 then move_train_prev_station(train_index)
      end
    end
  end

  def routes_manage
    if @routes.empty?
      puts 'Нет доступных маршрутов!'
      create_route
    else
      @routes.each_with_index do |route, index|
        puts "Индекс маршрута - #{index}, название: #{route.show_route.map(&:station_name)}"
      end
      puts 'Введите индекс маршрута: '
      route_index = gets.chomp.to_i
      puts ROUTE_MENU
      choose = gets.chomp.to_i
      case choose
      when 1 then add_stations_to_route(route_index)
      when 2 then delete_stations_from_route(route_index)
      end
    end
  end

  def wagons_manage
    puts 'Выберите индекс вагона'
    @wagons.each_with_index { |wagon, index| puts "#{index} #{wagon.wagon_type}" }
    wagon_index = gets.chomp.to_i
    if @wagons[wagon_index].instance_of?(CargoWagon)
      puts 'Заполнить грузовой вагон'
      puts 'Введите количество груза'
      wagon_volume = gets.chomp.to_i
      @wagons[wagon_index].take_volume(wagon_volume)
      puts 'Вагон заполнен'
    elsif @wagons[wagon_index].instance_of?(PassengerWagon)
      puts 'Заполнить пассажирский вагон'
      puts 'Введите количество пассажирских мест'
      wagon_places = gets.chomp.to_i
      @wagons[wagon_index].take_place(wagon_places)
      puts 'Место успешно занято'
    end
  end

  def create_station
    loop do
      puts 'Для добавления станций введите - 1'
      puts 'Когда завершите нажмите - 2'
      choose = gets.chomp.to_i
      case choose
      when 1
        print 'Введите название станции: '
        station_name = gets.chomp
        @stations << Station.new(station_name)
        puts 'Станция добавлена!'
      when 2
        puts 'Станции добавлены!!!'
        break
      end
    end
  rescue ArgumentError => e
    puts e.message
    puts 'Повторите попытку!'
    retry
  end

  def create_train
    puts 'Введите номер поезда: '
    train_number = gets.chomp
    puts 'Пассажирский = 1'
    puts 'Грузовой = 2'
    puts 'Введите тип поезда: '
    train_type = gets.chomp.to_i
    @trains << PassengerTrain.new(train_number) if train_type == 1
    @trains << CargoTrain.new(train_number) if train_type == 2
    puts 'Поезд добавлен'
  rescue ArgumentError => e
    puts e.message
    puts 'Повторите попытку!'
    retry
  end

  def create_route
    if @stations.empty?
      puts 'Нет доступных станций для создания маршрута!'
      create_station
    else
      @stations.each_with_index do |station, index|
        puts "Индекс станции #{index}: Название станции - #{station.station_name}"
      end
      puts 'Введите индекс начальной станции: '
      start_station_index = gets.chomp.to_i
      puts 'Введите индекс последней станции: '
      end_station_index = gets.chomp.to_i
      @routes << Route.new(@stations[start_station_index], @stations[end_station_index])
      puts 'Маршрут создан!'
    end
  rescue ArgumentError => e
    puts e.message
    puts 'Повторите попытку!'
    retry
  end

  def add_train_to_route(train_index)
    if @routes.empty?
      puts 'Нет доступных маршрутов!'
      create_route
    else
      @routes.each_with_index do |route, index|
        puts "Индекс маршрута - #{index}, название: #{route.show_route.map(&:station_name)}"
      end
      puts 'Введите индекс маршрута: '
      route_index = gets.chomp.to_i
      @trains[train_index].add_train_to_route(@routes[route_index])
      puts 'Поезд на маршруте! '
    end
  end

  def add_wagons_to_train(train_index)
    if @trains.empty?
      puts 'Нет доступных поездов!'
      create_train
    else
      case @trains[train_index].train_type
      when :cargo
        puts 'Введите объём вагона'
        wagon_volume = gets.chomp.to_i
        wagon = CargoWagon.new(:cargo, wagon_volume)
        puts 'Грузовой вагон успешно создан'
      when :passenger
        puts 'Введите количество мест в вагоне: '
        wagon_places = gets.chomp.to_i
        wagon = PassengerWagon.new(:passenger, wagon_places)
        puts 'Пассажирский вагон успешно создан'
      end
      @trains[train_index].add_wagon(wagon)
      @wagons << wagon
      puts 'Вагон прицеплен!'
    end
  rescue ArgumentError => e
    puts e.message
    retry
  end

  def delete_train_wagons(train_index)
    if @trains.empty?
      puts 'Нет доступных поездов!'
      create_train
    else
      puts 'Все вагоны отцеплены!' if @wagons.empty?
      @trains[train_index].delete_wagon
      puts 'Вагон отцеплен от поезда'
    end
  end

  def move_train_next_station(train_index)
    if @routes.empty?
      puts 'Нет доступных маршрутов!'
      create_route
    elsif @current_station != @end_station
      @trains[train_index].train_moving_next
      puts 'Поезд отправлен на следующею станцию!'
    else
      puts 'Поезд прибыл на конечную станцию!'

    end
  end

  def move_train_prev_station(train_index)
    if @routes.empty?
      puts 'Нет доступных маршрутов!'
      create_route
    else
      @trains[train_index].train_moving_prev
    end
  end

  def add_stations_to_route(route_index)
    if @routes.empty?
      puts 'Нет доступных маршрутов!'
      create_route
    else
      @stations.each_with_index do |station, index|
        puts "Индекс станции #{index}: Название станции - #{station.station_name}"
      end
      puts 'Введите индекс станции: '
      station_index = gets.chomp.to_i
      @route[route_index].add_intermediate_station(@stations[station_index])
      puts 'Станция добавлена на маршрут!'
    end
  end

  def delete_stations_from_route(route_index)
    if @routes.empty?
      puts 'Нет доступных маршрутов!'
      create_route
    else
      @stations.each_with_index do |station, index|
        puts "Индекс станции #{index}: Название станции - #{station.station_name}"
      end
      puts 'Введите индекс станции: '
      station_index = gets.chomp.to_i
      station = @routes[route_index].show_route[station_index]
      @route[route_index].delete_intermediate_station(station)
    end
  end
end

railway = Menu.new
railway.start_railway
