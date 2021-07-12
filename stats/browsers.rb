#   - Сколько всего уникальных браузеров +
#   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +

module Stats
  class Browsers
    attr_reader :sessions

    def initialize(sessions:)
      @sessions = sessions
    end

    def calculate
      report = {}

      unique_browsers = sessions.map {|s| s['browser'].upcase }.uniq.sort

      report['allBrowsers'] = unique_browsers.join(',')
      report['uniqueBrowsersCount'] = unique_browsers.count
      report['totalBrowsers'] = sessions.count

      report
    end
  end
end
