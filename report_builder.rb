# Отчёт в json
#   - Сколько всего юзеров +
#   - Сколько всего сессий +
#   - Статистика для браузеров из Stats::Browsers
#   - Статистика для юзеров из Stats::Users

Dir[File.join(__dir__, 'stats', '*.rb')].sort.each { |file| require file }

require 'oj'

class ReportBuilder
  attr_reader :lines_count
  attr_accessor :report

  MAX_BATCH_SIZE = 5000
  REPORT_FILE_NAME = './files/result.json'.freeze

  def initialize(lines_count:)
    @report = {
      'usersStats':    [],
      'totalUsers':    0,
      'totalSessions': 0,
      'allBrowsers':   Set.new
    }

    @lines_count = lines_count

    prepare_report_file
  end

  # подсчет статистики для одного пользователя и
  # обновление общей статистики по браузерам и сессиям
  def calc_user_stats(user, last_user: false)
    report[:usersStats].push(Stats::User.new(user: user).calculate)

    if report[:usersStats].size == batch_size
      save_current_batch_to_file(need_comma: !last_user)
    end

    update_group_stats(user)
  end

  def calc_last_user_stats(user)
    calc_user_stats(user, last_user: true)
    save_current_batch_to_file(last_batch: true)
  end

  # запись статистики основанной на всех пользователях
  def finish_report
    report[:uniqueBrowsersCount] = report[:allBrowsers].count
    report[:allBrowsers] = report[:allBrowsers].to_a.join(',')

    report.delete(:usersStats) # уже в файле со статистикой

    text = Oj.dump(report)[1..-1]
    File.open(REPORT_FILE_NAME, 'a') { |f| f << text }
  end

  private

  def batch_size
    # из примерного расчета что у пользователя в среднем 10 записей с сессиями
    @batch_size ||= [(lines_count / 100.0).ceil, MAX_BATCH_SIZE].min
  end

  # сохранение статистики для партии пользователей
  def save_current_batch_to_file(last_batch: false, need_comma: false)
    json = Oj.dump(report[:usersStats])

    # добавляем без скобок массива, чтобы в файле добавился в открытый массив
    text = json[2..-3]

    text += ', ' if need_comma
    text += '},' if last_batch

    # записываем результат в конец файла со статистикой
    File.open(REPORT_FILE_NAME, 'a') { |f| f << text }

    # убираем из памяти считанные данные, после записи статистики
    report[:usersStats] = []
  end

  # статистика вычисляемая по всем пользователям
  def update_group_stats(user)
    report[:allBrowsers].merge(user.browsers)
    report[:totalSessions] += user.sessions.count
    report[:totalUsers] += 1
  end

  def prepare_report_file
    FileUtils.rm(REPORT_FILE_NAME) if File.exist?(REPORT_FILE_NAME)
    File.open(REPORT_FILE_NAME, 'w') { |f| f.print(%({"usersStats":{)) }
  end
end