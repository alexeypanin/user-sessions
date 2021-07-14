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
      # Собираем количество сессий по пользователям
      report['sessionsCount'] = user.sessions.count

      # Собираем количество времени по пользователям
      report['totalTime'] = user.sessions.map {|s| s['time'].to_i}.sum.to_s + ' min.'

      # Выбираем самую длинную сессию пользователя
      report['longestSession'] = user.sessions.map {|s| s['time'].to_i}.max.to_s + ' min.'

      # Браузеры пользователя через запятую
      report['browsers'] = user.sessions.map {|s| s['browser'].upcase!}.sort.join(', ')

      # Хоть раз использовал IE?
      report['usedIE'] = user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ }

      # Всегда использовал только Chrome?
      report['alwaysUsedChrome'] = user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ }

      # Даты сессий через запятую в обратном порядке в формате iso8601
      report['dates'] = user.sessions.map{|s| Date.parse(s['date'])}.sort.reverse!.map { |d| d.iso8601 }

      { key => report }
    end

    private

    def key
      @key ||= [user.attributes['first_name'], user.attributes['last_name']].join(' ')
    end
  end
end