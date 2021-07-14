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

  BATCH_SIZE = 5_000 # для больших файлов, должен быть меньше кол-ва пользователей
  REPORT_FILE_NAME = './files/result.json'.freeze

  def initialize()
    @report = { usersStats: [],'totalUsers': 0, 'totalSessions': 0 }
    prepare_report_file
  end

  # подсчет статистики для одного пользователя и
  # обновление общей статистики по браузерам и сессиям
  def calc_user_stats user, last_user: false
    report[:usersStats].push(Stats::User.new(user: user).calculate)

    if report[:usersStats].size == BATCH_SIZE
      save_current_batch_to_file(need_comma: !last_user)
    end

    update_group_stats(user)
  end

  def calc_last_user_stats user
    calc_user_stats(user, last_user: true)
    save_current_batch_to_file(last_batch: true)
  end

  # запись статистики основанной на всех пользователях
  def finish_report
    report[:uniqueBrowsersCount] = report[:allBrowsers].count
    report[:allBrowsers] = report[:allBrowsers].to_a.join(',')

    report.delete(:usersStats) # уже в файле со статистикой

    text = report.to_json[1..-1]
    File.open(REPORT_FILE_NAME, 'a') {|f| f << text }
  end

  private

  # сохранение статистики для партии пользователей
  def save_current_batch_to_file(last_batch: false, need_comma: false)
    json = report[:usersStats].to_json

    # добавляем без скобок массива, чтобы в файле добавился в открытый массив
    text = json[2..-3]

    text += ', ' if need_comma
    text += "}," if last_batch

    # записываем результат в конец файла со статистикой
    File.open(REPORT_FILE_NAME, 'a') {|f| f << text }

    # убираем из памяти считанные данные, после записи статистики
    report[:usersStats] = []
  end

  # статистика вычисляемая по всем пользователям
  def update_group_stats user
    user_browsers = user.sessions.map {|s| s['browser'].upcase }

    report[:allBrowsers] ||= Set.new
    report[:allBrowsers].merge(user_browsers)
    report[:totalUsers] += 1
    report[:totalSessions] += user.sessions.count
  end

  def prepare_report_file
    FileUtils.rm(REPORT_FILE_NAME) if File.exists?(REPORT_FILE_NAME)
    File.open(REPORT_FILE_NAME, 'w') {|f| f.print(%Q({"usersStats":{))}
  end
end