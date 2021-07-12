Dir[File.join(__dir__, 'parsers', '*.rb')].each { |file| require file }

require 'active_support'
require 'active_support/core_ext'

class DataParser
  PARSERS = %w(user session).freeze

  attr_reader :file_name

  def initialize(file_name: '../files/data.txt')
    @file_name = file_name
  end

  def parse
    objects = { users: [] }
    current_user = nil
    i = 0

    File.foreach(file_name).each_entry do |line|
      object_name = line.split(',').first

      unless PARSERS.include?(object_name)
        raise ArgumentError.new("Parser for object #{object_name} not exists")
      end

      object = parser(object_name).new(line).parse

      # если начались записи нового пользователя то записываем current_user в objects
      if object_name == 'user'
        objects[:users] << current_user if current_user
        current_user = object
      elsif object_name == 'session' # если сессия, то добавляем ее к current_user
        current_user.sessions << object if current_user
      end

      # запись последнего пользователя
      if i == lines_count - 1
        objects[:users] << current_user if current_user
      end

      display_progress(i)
      i+=1
    end

    objects.symbolize_keys
  end

  private

  def parser object_name
    "Parsers::#{object_name.classify}".constantize
  end

  def lines_count
    @l_count ||= `wc -l #{file_name}`.to_i
  end

  def display_progress index
    progress = ((index).to_f / lines_count * 100).round(2)
    printf("\rImport progress: #{progress}%%")
  end
end
