#   - По каждому пользователю
#     - сколько всего сессий +
#     - сколько всего времени +
#     - самая длинная сессия +
#     - браузеры через запятую +
#     - Хоть раз использовал IE? +
#     - Всегда использовал только Хром? +
#     - даты сессий в порядке убывания через запятую +

module Stats
  class User
    attr_reader :user
    attr_accessor :report

    def initialize(user:)
      @user = user
      @report = {}
    end

    def calculate
      session_stats
      browsers_stats

      { key => report }
    end

    private

    def key
      @key ||= [user.attributes['first_name'], user.attributes['last_name']].join(' ')
    end

    def session_stats
      # Собираем количество сессий по пользователям
      report['sessionsCount'] = user.sessions.count

      # Собираем количество времени по пользователям
      report['totalTime'] = "#{session_durations.sum} min."

      # Выбираем самую длинную сессию пользователя
      report['longestSession'] = "#{session_durations.max} min."

      # Даты сессий через запятую в обратном порядке в формате iso8601
      report['dates'] = session_dates.sort!.reverse!.map(&:iso8601)
    end

    def browsers_stats
      # Браузеры пользователя через запятую
      report['browsers'] = user.browsers.sort.join(', ')

      # Хоть раз использовал IE?
      report['usedIE'] = user.browsers.any? { |b| b =~ /INTERNET EXPLORER/ }

      # Всегда использовал только Chrome?
      report['alwaysUsedChrome'] = user.browsers.all? { |b| b =~ /CHROME/ }
    end

    def session_durations
      @session_durations ||= user.sessions.map { |s| s['time'].to_i }
    end

    def session_dates
      @session_dates ||= user.sessions.map { |s| s['date'] }
    end
  end
end
