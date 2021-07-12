# Отчёт в json
#   - Сколько всего юзеров +
#   - Сколько всего сессий +
#   - Статистика для браузеров из Stats::Browsers
#   - Статистика для юзеров из Stats::Users

Dir[File.join(__dir__, 'stats', '*.rb')].each { |file| require file }

require 'json'

class ReportBuilder
  attr_reader :objects
  attr_accessor :report

  def initialize(objects:)
    @objects = objects
    @report = Hash.new
  end

  def call
    sessions = objects[:users].map {|user| user.sessions }.flatten

    report.merge!(Stats::Browsers.new(sessions: sessions).calculate)
    report.merge!(Stats::Users.new(users: objects[:users]).calculate)

    File.write('./files/result.json', "#{report.to_json}\n")
  end
end