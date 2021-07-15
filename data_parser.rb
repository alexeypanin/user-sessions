Dir[File.join(__dir__, 'parsers', '*.rb')].each { |file| require file }

require File.join(__dir__, 'report_builder')

require 'active_support'
require 'active_support/core_ext'

class DataParser
  PARSERS = %w(user session).freeze

  attr_reader :file_name
  attr_accessor :report_builder

  def initialize(file_name: '../files/data.txt')
    @file_name = file_name
    @report_builder = ReportBuilder.new(lines_count: lines_count)
  end

  # генерируем статистику по ходу считывания файла и записываем
  # частями в файл отчета, чтобы не накапливать большой массив данных в памяти
  def parse
    current_user = nil

    i = 0
    File.foreach(file_name).each_entry do |line|
      object_name = line.split(',').first
      check_object_validity!(object_name)

      object = parser(object_name).new(line).parse

      # если начались записи нового пользователя то считаем статистику
      # для current_user, затем меням current_user-а на нового
      if object_name == 'user'
        report_builder.calc_user_stats(current_user) if current_user
        current_user = object
      elsif object_name == 'session' # если сессия, то добавляем ее к current_user-у
        current_user.sessions << object if current_user
      end

      # считаем статистику для последнего пользователя
      if i == lines_count || line.blank?
        report_builder.calc_last_user_stats(current_user)
      end

      display_progress(i)
      i+=1
    end

    # в конце записываем статистику которая считается по всем пользователям
    report_builder.finish_report
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

  def check_object_validity!(object_name)
    unless PARSERS.include?(object_name)
      raise ArgumentError.new("Parser for object #{object_name} not exists")
    end
  end
end
