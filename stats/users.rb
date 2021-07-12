#   - По каждому пользователю
#     - сколько всего сессий +
#     - сколько всего времени +
#     - самая длинная сессия +
#     - браузеры через запятую +
#     - Хоть раз использовал IE? +
#     - Всегда использовал только Хром? +
#     - даты сессий в порядке убывания через запятую +

module Stats
  class Users
    attr_reader :users
    attr_accessor :report

    def initialize(users:)
      @users = users
      @report = {}
    end

    def calculate
      # Собираем количество сессий по пользователям
      collect_stats_from_users do |user|
        { 'sessionsCount' => user.sessions.count }
      end

      # Собираем количество времени по пользователям
      collect_stats_from_users do |user|
        { 'totalTime' => user.sessions.map {|s| s['time'].to_i}.sum.to_s + ' min.' }
      end

      # Выбираем самую длинную сессию пользователя
      collect_stats_from_users do |user|
        { 'longestSession' => user.sessions.map {|s| s['time'].to_i}.max.to_s + ' min.' }
      end

      # Браузеры пользователя через запятую
      collect_stats_from_users do |user|
        { 'browsers' => user.sessions.map {|s| s['browser'].upcase}.sort.join(', ') }
      end

      # Хоть раз использовал IE?
      collect_stats_from_users do |user|
        { 'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
      end

      # Всегда использовал только Chrome?
      collect_stats_from_users do |user|
        { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ } }
      end

      # Даты сессий через запятую в обратном порядке в формате iso8601
      collect_stats_from_users do |user|
        { 'dates' => user.sessions.map{|s| Date.parse(s['date'])}.sort.reverse.map { |d| d.iso8601 } }
      end

      { 'totalUsers': users.count, 'usersStats': report }
    end

    private

    def collect_stats_from_users(&block)
      users.each do |user|
        report[user_key(user)] ||= {}
        report[user_key(user)].merge!(block.call(user))
      end
    end

    def user_key user
      [user.attributes['first_name'], user.attributes['last_name']].join(' ')
    end
  end
end